import Foundation
import Observation

/// The app's data: the user's aircraft and the aircraft types used to create them.
@MainActor
@Observable
final class Library {
    var aircraft: [Aircraft]
    var types: [AircraftType]

    /// Set when the last save failed, so the UI can tell the user.
    var saveError: String?

    @ObservationIgnored private let storage: LibraryStorage?
    @ObservationIgnored private var lastSaved: LibrarySnapshot?

    /// Loads from `storage`, or starts empty and never saves when `storage` is `nil` (previews, tests).
    init(storage: LibraryStorage?) {
        self.storage = storage
        if let storage {
            let (snapshot, source) = storage.load()
            aircraft = snapshot.aircraft
            types = snapshot.types
            // Write the converted data straight away so migration only happens once.
            lastSaved = source == .saved ? snapshot : nil
        } else {
            aircraft = []
            types = []
        }
    }

    init(aircraft: [Aircraft], types: [AircraftType]) {
        storage = nil
        self.aircraft = aircraft
        self.types = types
    }

    var snapshot: LibrarySnapshot {
        LibrarySnapshot(aircraft: aircraft, types: types)
    }

    /// Writes the library to disk if anything changed since the last save.
    func save() {
        guard let storage else { return }
        let current = snapshot
        guard current != lastSaved else { return }
        do {
            try storage.save(current)
            lastSaved = current
            saveError = nil
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: Aircraft

    @discardableResult
    func addAircraft(tailNumber: String, type: AircraftType?) -> Aircraft {
        let new = if let type {
            Aircraft(tailNumber: tailNumber, type: type)
        } else {
            Aircraft(tailNumber: tailNumber, typeName: "")
        }
        aircraft.append(new)
        return new
    }

    /// Replaces the stored aircraft that has the same ID. Does nothing if it has been deleted.
    func update(_ updated: Aircraft) {
        guard let index = aircraft.firstIndex(where: { $0.id == updated.id }) else { return }
        aircraft[index] = updated
    }

    func deleteAircraft(at offsets: IndexSet) {
        aircraft.removeElements(atOffsets: offsets)
    }

    func moveAircraft(from source: IndexSet, to destination: Int) {
        aircraft.moveElements(fromOffsets: source, toOffset: destination)
    }

    // MARK: Types

    @discardableResult
    func addType(name: String = "") -> AircraftType {
        let new = AircraftType(name: name)
        types.append(new)
        return new
    }

    /// Replaces the stored type that has the same ID. Does nothing if it has been deleted.
    func update(_ updated: AircraftType) {
        guard let index = types.firstIndex(where: { $0.id == updated.id }) else { return }
        types[index] = updated
    }

    func deleteTypes(at offsets: IndexSet) {
        types.removeElements(atOffsets: offsets)
    }

    func moveTypes(from source: IndexSet, to destination: Int) {
        types.moveElements(fromOffsets: source, toOffset: destination)
    }
}

// SwiftUI provides `remove(atOffsets:)` and `move(fromOffsets:toOffset:)`, but the model layer
// doesn't import SwiftUI so it can be tested with `swift test` on any platform.
private extension Array {
    mutating func removeElements(atOffsets offsets: IndexSet) {
        for index in offsets.reversed() {
            remove(at: index)
        }
    }

    mutating func moveElements(fromOffsets source: IndexSet, toOffset destination: Int) {
        let moving = source.map { self[$0] }
        let destinationAfterRemoval = destination - source.filter { $0 < destination }.count
        removeElements(atOffsets: source)
        insert(contentsOf: moving, at: destinationAfterRemoval)
    }
}
