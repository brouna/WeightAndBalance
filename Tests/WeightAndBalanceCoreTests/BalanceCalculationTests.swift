import Foundation
import Testing
@testable import WeightAndBalanceCore

@Suite("Weight and balance calculation")
struct BalanceCalculationTests {
    /// The SR22T/TN from the bundled defaults.
    static let sr22t = AircraftConfiguration(
        emptyWeight: 2489, emptyArm: 139.5,
        frontSeatArm: 143.5, rearSeatArm: 180,
        fuelCapacity: 92, fuelArm: 154.9,
        maxBaggageWeight: 130, baggageArm: 208,
        tksCapacity: 3.5, tksArm: 148,
        oxygenWeight: 23.8, oxygenArm: 265.3,
        maxGrossWeight: 3400,
        envelope: [
            EnvelopePoint(weight: 2100, arm: 137.8),
            EnvelopePoint(weight: 2700, arm: 139.1),
            EnvelopePoint(weight: 3400, arm: 142.3),
            EnvelopePoint(weight: 3400, arm: 148.1),
            EnvelopePoint(weight: 2100, arm: 148.1),
        ]
    )

    @Test func totalsMatchHandCalculation() throws {
        let aircraft = Aircraft(
            tailNumber: "N1", typeName: "SR22T/TN", configuration: Self.sr22t,
            loading: Loading(frontLeft: 190, frontRight: 160, rearLeft: 45, rearRight: 0,
                             baggage: 40, fuel: 60, tksFull: true, oxygenAboard: true)
        )
        let result = aircraft.balance()

        // (weight lb, arm in) for: empty, front row, rear row, 60 gal fuel, baggage, TKS, oxygen.
        let items: [(Double, Double)] = [
            (2489, 139.5), (350, 143.5), (45, 180), (360, 154.9), (40, 208), (3.5 * 9.1, 148), (23.8, 265.3),
        ]
        let expectedWeight = items.reduce(0) { $0 + $1.0 }
        let expectedMoment = items.reduce(0) { $0 + $1.0 * $1.1 }
        #expect(abs(result.totalWeight - expectedWeight) < 1e-9)
        #expect(abs(result.totalMoment - expectedMoment) < 1e-6)
        let cg = try #require(result.centerOfGravity)
        #expect(abs(cg - expectedMoment / expectedWeight) < 1e-9)

        #expect(result.isWithinMaxGross)
        #expect(result.isFuelWithinCapacity)
        #expect(result.isBaggageWithinLimit)
        #expect(result.envelopeStatus == .within)
        #expect(result.isWithinAllLimits)
    }

    @Test func optionalEquipmentOnlyListedWhenInstalled() {
        var config = Self.sr22t
        config.tksCapacity = 0
        config.oxygenWeight = 0
        let aircraft = Aircraft(tailNumber: "N1", typeName: "SR22", configuration: config)
        #expect(aircraft.loadLines.map(\.name) == ["Basic empty", "Front row", "Rear row", "Fuel", "Baggage"])
    }

    @Test func switchedOffEquipmentWeighsNothing() {
        let aircraft = Aircraft(tailNumber: "N1", typeName: "", configuration: Self.sr22t)
        let lines = aircraft.loadLines
        #expect(lines.first { $0.name == "TKS" }?.weight == 0)
        #expect(lines.first { $0.name == "Oxygen" }?.weight == 0)
    }

    @Test func overGrossIsReported() {
        let aircraft = Aircraft(
            tailNumber: "N1", typeName: "", configuration: Self.sr22t,
            loading: Loading(frontLeft: 250, frontRight: 250, rearLeft: 200, rearRight: 200, baggage: 100, fuel: 92)
        )
        let result = aircraft.balance()
        #expect(!result.isWithinMaxGross)
        #expect(abs(result.weightOverMaxGross - (result.totalWeight - 3400)) < 1e-9)
        #expect(result.envelopeStatus == .outside)
        #expect(!result.isWithinAllLimits)
    }

    @Test func fuelAndBaggageLimits() {
        let aircraft = Aircraft(
            tailNumber: "N1", typeName: "", configuration: Self.sr22t,
            loading: Loading(frontLeft: 170, baggage: 131, fuel: 92.5)
        )
        let result = aircraft.balance()
        #expect(!result.isFuelWithinCapacity)
        #expect(!result.isBaggageWithinLimit)
        #expect(!result.isWithinAllLimits)
    }

    @Test func insufficientEnvelope() {
        var config = Self.sr22t
        config.envelope = Array(config.envelope.prefix(2))
        let aircraft = Aircraft(tailNumber: "N1", typeName: "", configuration: config,
                                loading: Loading(frontLeft: 170))
        #expect(aircraft.balance().envelopeStatus == .insufficientEnvelope)
    }

    @Test func zeroWeightHasNoCG() {
        let aircraft = Aircraft(tailNumber: "N1", typeName: "", configuration: AircraftConfiguration(
            envelope: Self.sr22t.envelope
        ))
        let result = aircraft.balance()
        #expect(result.centerOfGravity == nil)
        #expect(result.envelopeStatus == .noWeight)
    }

    @Test func aftCGIsOutside() {
        // Everything loaded far aft: weight is fine but CG is behind the 148.1 in limit.
        var config = Self.sr22t
        config.baggageArm = 400
        let aircraft = Aircraft(tailNumber: "N1", typeName: "", configuration: config,
                                loading: Loading(frontLeft: 170, baggage: 130, fuel: 30))
        let result = aircraft.balance()
        #expect(result.isWithinMaxGross)
        #expect(result.envelopeStatus == .outside)
    }
}

@Suite("Envelope containment")
struct EnvelopeTests {
    let square = [
        EnvelopePoint(weight: 0, arm: 0),
        EnvelopePoint(weight: 10, arm: 0),
        EnvelopePoint(weight: 10, arm: 10),
        EnvelopePoint(weight: 0, arm: 10),
    ]

    @Test func insideAndOutside() {
        #expect(Envelope.contains(arm: 5, weight: 5, in: square))
        #expect(!Envelope.contains(arm: 11, weight: 5, in: square))
        #expect(!Envelope.contains(arm: 5, weight: -1, in: square))
    }

    @Test func boundaryCountsAsInside() {
        #expect(Envelope.contains(arm: 0, weight: 5, in: square))
        #expect(Envelope.contains(arm: 10, weight: 10, in: square))
        #expect(Envelope.contains(arm: 5, weight: 10, in: square))
    }

    @Test func pointOrderDoesNotMatter() {
        #expect(Envelope.contains(arm: 5, weight: 5, in: square.reversed()))
    }

    @Test func sr22tMaxGrossEdge() {
        let envelope = BalanceCalculationTests.sr22t.envelope
        #expect(Envelope.contains(arm: 145, weight: 3400, in: envelope))
        #expect(!Envelope.contains(arm: 145, weight: 3400.5, in: envelope))
        #expect(!Envelope.contains(arm: 138.5, weight: 3000, in: envelope))  // forward of the sloped limit
        #expect(Envelope.contains(arm: 141, weight: 3000, in: envelope))
    }

    @Test func tooFewPoints() {
        #expect(!Envelope.contains(arm: 0, weight: 0, in: Array(square.prefix(2))))
    }
}
