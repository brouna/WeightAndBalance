import Foundation
import Testing
@testable import WeightAndBalanceCore

@Suite("Legacy archive migration")
struct LegacyArchiveTests {
    @Test func decodesBundledTypesArchive() throws {
        let types = try LegacyArchive.decodeTypes(from: Fixtures.data("legacy-types.archive"))
        #expect(types.map(\.name) == ["SR22", "SR22T/TN", "PA-28R-201", "PA-28-161", "R44"])

        let sr22t = try #require(types.first { $0.name == "SR22T/TN" })
        let config = sr22t.configuration
        // Float artefacts (137.8000030517578) must be cleaned up to what the user typed.
        #expect(config.envelope.map(\.arm) == [137.8, 139.1, 142.3, 148.1, 148.1])
        #expect(config.envelope.map(\.weight) == [2100, 2700, 3400, 3400, 2100])
        #expect(config.emptyWeight == 2489)
        #expect(config.emptyArm == 139.5)
        #expect(config.frontSeatArm == 143.5)
        #expect(config.rearSeatArm == 180)
        #expect(config.fuelCapacity == 92)
        #expect(config.fuelArm == 154.9)
        #expect(config.maxBaggageWeight == 130)
        #expect(config.baggageArm == 208)
        #expect(config.tksCapacity == 3.5)
        #expect(config.tksArm == 148)
        #expect(config.oxygenWeight == 23.8)
        #expect(config.oxygenArm == 265.3)
        #expect(config.maxGrossWeight == 3400)
    }

    @Test func decodesAircraftArchive() throws {
        let aircraft = try LegacyArchive.decodeAircraft(from: Fixtures.data("legacy-aircraft.archive"))
        #expect(aircraft.count == 2)

        let plane = aircraft[0]
        #expect(plane.tailNumber == "N123AB")
        #expect(plane.typeName == "SR22T/TN")
        #expect(plane.configuration.emptyWeight == 2489)
        #expect(plane.configuration.fuelArm == 154.9)
        #expect(plane.configuration.oxygenWeight == 23.8)
        #expect(plane.configuration.envelope.count == 5)
        #expect(plane.loading == Loading(
            frontLeft: 190, frontRight: 160, rearLeft: 45, rearRight: 0,
            baggage: 40, fuel: 60, tksFull: true, oxygenAboard: false
        ))

        // Nil values in old archives become zero rather than failing the whole migration.
        let blank = aircraft[1]
        #expect(blank.tailNumber == "New")
        #expect(blank.typeName == "")
        #expect(blank.configuration.maxGrossWeight == 0)
        #expect(blank.configuration.envelope == [EnvelopePoint(id: blank.configuration.envelope[0].id, weight: 0, arm: 0)])
    }

    @Test func rejectsGarbage() {
        #expect(throws: (any Error).self) {
            try LegacyArchive.decodeTypes(from: Data("not an archive".utf8))
        }
    }

    @Test(arguments: [
        (137.8000030517578, 137.8),
        (23.799999237060547, 23.8),
        (9.1, 9.1),          // stored as a double: unchanged
        (2489.0, 2489.0),
        (0.1 + 0.2, 0.1 + 0.2), // not representable as Float: unchanged
    ])
    func cleansFloatArtefacts(input: Double, expected: Double) {
        #expect(cleanLegacyDouble(NSNumber(value: input)) == expected)
    }

    @Test func bundledDefaultTypesMatchLegacyArchive() throws {
        let legacy = try LegacyArchive.decodeTypes(from: Fixtures.data("legacy-types.archive"))
        let bundled = try JSONDecoder().decode(
            [AircraftType].self,
            from: Data(contentsOf: Fixtures.defaultTypesURL)
        )
        #expect(bundled.map(\.name) == legacy.map(\.name))
        for (b, l) in zip(bundled, legacy) {
            var lConfig = l.configuration
            // IDs are generated on decode, so compare everything else.
            lConfig.envelope = zip(lConfig.envelope, b.configuration.envelope).map { point, bundledPoint in
                EnvelopePoint(id: bundledPoint.id, weight: point.weight, arm: point.arm)
            }
            #expect(b.configuration == lConfig, "\(b.name)")
        }
    }
}
