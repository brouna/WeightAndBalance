import Foundation

/// Everything the app persists.
struct LibrarySnapshot: Codable, Equatable, Sendable {
    static let currentVersion = 1

    var version = LibrarySnapshot.currentVersion
    var aircraft: [Aircraft]
    var types: [AircraftType]
}

/// Loads and saves the library as JSON, migrating data from the Objective-C app on first launch.
struct LibraryStorage: Sendable {
    enum Source: Equatable, Sendable {
        /// Loaded from the current JSON file.
        case saved
        /// Converted from the old `NSKeyedArchiver` files.
        case migrated
        /// Nothing saved yet; started from the bundled default types.
        case defaults
    }

    static let fileName = "library.json"
    static let legacyAircraftFileName = "aircraft.archive"
    static let legacyTypesFileName = "types.v2.archive"

    /// Where `library.json` lives (Application Support).
    var directory: URL
    /// Where the Objective-C app kept its archives (Documents).
    var legacyDirectory: URL
    /// JSON array of `AircraftType` shipped with the app.
    var defaultTypesURL: URL?

    var fileURL: URL { directory.appendingPathComponent(Self.fileName) }

    static func standard(bundle: Bundle = .main) -> LibraryStorage {
        let fileManager = FileManager.default
        return LibraryStorage(
            directory: fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0],
            legacyDirectory: fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0],
            defaultTypesURL: bundle.url(forResource: "DefaultTypes", withExtension: "json")
        )
    }

    func load() -> (snapshot: LibrarySnapshot, source: Source) {
        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                return (try JSONDecoder().decode(LibrarySnapshot.self, from: data), .saved)
            } catch {
                // Keep the unreadable file rather than overwrite it on the next save.
                let stamp = Int(Date().timeIntervalSince1970)
                let aside = directory.appendingPathComponent("library-unreadable-\(stamp).json")
                try? fileManager.moveItem(at: fileURL, to: aside)
            }
        }

        if let migrated = migrateLegacyArchives() {
            return (migrated, .migrated)
        }

        return (LibrarySnapshot(aircraft: [], types: defaultTypes()), .defaults)
    }

    func save(_ snapshot: LibrarySnapshot) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(snapshot).write(to: fileURL, options: .atomic)
    }

    /// Reads the Objective-C app's archives, if any. The archives are left in place.
    func migrateLegacyArchives() -> LibrarySnapshot? {
        let aircraftURL = legacyDirectory.appendingPathComponent(Self.legacyAircraftFileName)
        let typesURL = legacyDirectory.appendingPathComponent(Self.legacyTypesFileName)

        let aircraftData = try? Data(contentsOf: aircraftURL)
        let typesData = try? Data(contentsOf: typesURL)
        guard aircraftData != nil || typesData != nil else { return nil }

        let aircraft = aircraftData.flatMap { try? LegacyArchive.decodeAircraft(from: $0) } ?? []
        let types = typesData.flatMap { try? LegacyArchive.decodeTypes(from: $0) } ?? defaultTypes()
        return LibrarySnapshot(aircraft: aircraft, types: types)
    }

    func defaultTypes() -> [AircraftType] {
        guard let url = defaultTypesURL, let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([AircraftType].self, from: data)) ?? []
    }
}
