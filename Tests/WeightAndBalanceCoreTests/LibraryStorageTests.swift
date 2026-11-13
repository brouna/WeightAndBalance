import Foundation
import Testing
@testable import WeightAndBalanceCore

@Suite("Library storage and migration")
struct LibraryStorageTests {
    func makeStorage() throws -> LibraryStorage {
        let root = try Fixtures.temporaryDirectory()
        let legacy = root.appendingPathComponent("Documents")
        try FileManager.default.createDirectory(at: legacy, withIntermediateDirectories: true)
        return LibraryStorage(
            directory: root.appendingPathComponent("Application Support"),
            legacyDirectory: legacy,
            defaultTypesURL: Fixtures.defaultTypesURL
        )
    }

    @Test func freshInstallStartsWithDefaultTypes() throws {
        let storage = try makeStorage()
        let (snapshot, source) = storage.load()
        #expect(source == .defaults)
        #expect(snapshot.aircraft.isEmpty)
        #expect(snapshot.types.map(\.name) == ["SR22", "SR22T/TN", "PA-28R-201", "PA-28-161", "R44"])
    }

    @Test func migratesLegacyArchivesThenPrefersJSON() throws {
        let storage = try makeStorage()
        let fileManager = FileManager.default
        try fileManager.copyItem(
            at: Fixtures.url("legacy-aircraft.archive"),
            to: storage.legacyDirectory.appendingPathComponent("aircraft.archive")
        )
        try fileManager.copyItem(
            at: Fixtures.url("legacy-types.archive"),
            to: storage.legacyDirectory.appendingPathComponent("types.v2.archive")
        )

        let (migrated, source) = storage.load()
        #expect(source == .migrated)
        #expect(migrated.aircraft.map(\.tailNumber) == ["N123AB", "New"])
        #expect(migrated.types.count == 5)

        // Edits are saved as JSON and win over the legacy files, which are left untouched.
        var edited = migrated
        edited.aircraft[0].tailNumber = "N999ZZ"
        try storage.save(edited)
        let (reloaded, reloadedSource) = storage.load()
        #expect(reloadedSource == .saved)
        #expect(reloaded == edited)
        #expect(fileManager.fileExists(atPath: storage.legacyDirectory.appendingPathComponent("aircraft.archive").path))
    }

    @Test func legacyAircraftWithoutTypesFallsBackToDefaults() throws {
        let storage = try makeStorage()
        try FileManager.default.copyItem(
            at: Fixtures.url("legacy-aircraft.archive"),
            to: storage.legacyDirectory.appendingPathComponent("aircraft.archive")
        )
        let (snapshot, source) = storage.load()
        #expect(source == .migrated)
        #expect(snapshot.aircraft.count == 2)
        #expect(snapshot.types.count == 5)
    }

    @Test func unreadableJSONIsSetAsideNotOverwritten() throws {
        let storage = try makeStorage()
        try FileManager.default.createDirectory(at: storage.directory, withIntermediateDirectories: true)
        try Data("{ corrupt".utf8).write(to: storage.fileURL)

        let (_, source) = storage.load()
        #expect(source == .defaults)
        let files = try FileManager.default.contentsOfDirectory(atPath: storage.directory.path)
        #expect(files.contains { $0.hasPrefix("library-unreadable-") })
        #expect(!files.contains(LibraryStorage.fileName))
    }

    @MainActor
    @Test func librarySavesOnlyWhenChanged() throws {
        let storage = try makeStorage()
        let library = Library(storage: storage)
        // Defaults are written on the first save so that later launches load JSON.
        library.save()
        #expect(storage.load().source == .saved)

        let type = try #require(library.types.first)
        let added = library.addAircraft(tailNumber: "N55", type: type)
        #expect(added.configuration == type.configuration)
        #expect(added.typeName == type.name)
        library.save()
        #expect(storage.load().snapshot.aircraft.map(\.tailNumber) == ["N55"])
        #expect(library.saveError == nil)
    }

    @MainActor
    @Test func reorderAndDelete() {
        let library = Library(aircraft: ["A", "B", "C", "D"].map { Aircraft(tailNumber: $0, typeName: "") }, types: [])
        library.moveAircraft(from: [0], to: 3)
        #expect(library.aircraft.map(\.tailNumber) == ["B", "C", "A", "D"])
        library.moveAircraft(from: [3], to: 0)
        #expect(library.aircraft.map(\.tailNumber) == ["D", "B", "C", "A"])
        library.deleteAircraft(at: [1, 2])
        #expect(library.aircraft.map(\.tailNumber) == ["D", "A"])

        var edited = library.aircraft[1]
        edited.loading.fuel = 40
        library.update(edited)
        #expect(library.aircraft[1].loading.fuel == 40)

        // Updating an aircraft that was deleted elsewhere is ignored rather than re-adding it.
        library.deleteAircraft(at: [1])
        library.update(edited)
        #expect(library.aircraft.map(\.tailNumber) == ["D"])
    }

    @Test func reportMentionsKeyFigures() {
        let aircraft = Aircraft(
            tailNumber: "N123AB", typeName: "SR22T/TN",
            configuration: BalanceCalculationTests.sr22t,
            loading: Loading(frontLeft: 190, fuel: 60)
        )
        let report = aircraft.loadReport(date: Date(timeIntervalSince1970: 0), locale: Locale(identifier: "en_US"))
        #expect(report.contains("SR22T/TN N123AB"))
        #expect(report.contains("Front row: 190.0 lb at 143.5 in"))
        #expect(report.contains("Envelope: In balance"))
        #expect(report.contains("Result: within all limits"))
    }
}
