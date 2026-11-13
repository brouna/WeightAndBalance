import Foundation

extension Library {
    /// Sample data for SwiftUI previews. Not behind `#if DEBUG` because `#Preview` code is also
    /// compiled in Release builds.
    @MainActor static let preview: Library = {
        let envelope = [
            EnvelopePoint(weight: 2100, arm: 137.8),
            EnvelopePoint(weight: 2700, arm: 139.1),
            EnvelopePoint(weight: 3400, arm: 142.3),
            EnvelopePoint(weight: 3400, arm: 148.1),
            EnvelopePoint(weight: 2100, arm: 148.1),
        ]
        let sr22t = AircraftType(name: "SR22T", configuration: AircraftConfiguration(
            emptyWeight: 2489, emptyArm: 139.5,
            frontSeatArm: 143.5, rearSeatArm: 180,
            fuelCapacity: 92, fuelArm: 154.9,
            maxBaggageWeight: 130, baggageArm: 208,
            tksCapacity: 3.5, tksArm: 148,
            oxygenWeight: 23.8, oxygenArm: 265.3,
            maxGrossWeight: 3400,
            envelope: envelope
        ))
        var aircraft = Aircraft(tailNumber: "N123AB", type: sr22t)
        aircraft.loading = Loading(frontLeft: 190, frontRight: 160, rearLeft: 45, baggage: 40, fuel: 60, tksFull: true)
        return Library(aircraft: [aircraft], types: [sr22t])
    }()
}
