import Foundation

/// One corner of a weight-and-balance envelope (a point on the CG limits chart).
struct EnvelopePoint: Codable, Hashable, Identifiable, Sendable {
    var id = UUID()
    /// Weight in pounds.
    var weight: Double
    /// Arm (CG position) in inches aft of the datum.
    var arm: Double

    init(id: UUID = UUID(), weight: Double, arm: Double) {
        self.id = id
        self.weight = weight
        self.arm = arm
    }
}

/// The fixed, per-airframe data needed to compute weight and balance.
///
/// Aircraft types (templates) and individual aircraft both carry one of these;
/// creating an aircraft from a type copies the type's configuration.
struct AircraftConfiguration: Codable, Hashable, Sendable {
    static let fuelPoundsPerGallon = 6.0
    static let tksPoundsPerGallon = 9.1

    /// Basic empty weight (lb) and its arm (in).
    var emptyWeight = 0.0
    var emptyArm = 0.0

    /// Arms of the front and rear rows of seats (in).
    var frontSeatArm = 0.0
    var rearSeatArm = 0.0

    /// Usable fuel capacity (gal) and arm (in).
    var fuelCapacity = 0.0
    var fuelArm = 0.0

    /// Maximum baggage weight (lb) and arm (in).
    var maxBaggageWeight = 0.0
    var baggageArm = 0.0

    /// TKS de-ice fluid capacity (gal) and arm (in). A capacity of zero means not installed.
    var tksCapacity = 0.0
    var tksArm = 0.0

    /// Weight of the oxygen system when carried (lb) and its arm (in). Zero means not installed.
    var oxygenWeight = 0.0
    var oxygenArm = 0.0

    /// Maximum gross weight (lb).
    var maxGrossWeight = 0.0

    /// CG envelope, in drawing order. At least three points are needed to form a polygon.
    var envelope: [EnvelopePoint] = []

    var hasTKS: Bool { tksCapacity > 0 }
    var hasOxygen: Bool { oxygenWeight > 0 }
}

/// A template describing a make/model, used to create aircraft.
struct AircraftType: Codable, Hashable, Identifiable, Sendable {
    var id = UUID()
    var name: String
    var configuration: AircraftConfiguration

    init(id: UUID = UUID(), name: String, configuration: AircraftConfiguration = AircraftConfiguration()) {
        self.id = id
        self.name = name
        self.configuration = configuration
    }
}

/// What is on board for a particular flight.
struct Loading: Codable, Hashable, Sendable {
    /// Occupant weights (lb).
    var frontLeft = 0.0
    var frontRight = 0.0
    var rearLeft = 0.0
    var rearRight = 0.0
    /// Baggage weight (lb).
    var baggage = 0.0
    /// Fuel on board (gal).
    var fuel = 0.0
    /// TKS tank full (true) or empty (false).
    var tksFull = false
    /// Oxygen system carried.
    var oxygenAboard = false
}

/// A specific airframe, identified by its tail number.
struct Aircraft: Codable, Hashable, Identifiable, Sendable {
    var id = UUID()
    var tailNumber: String
    var typeName: String
    var configuration: AircraftConfiguration
    var loading: Loading

    init(
        id: UUID = UUID(),
        tailNumber: String,
        typeName: String,
        configuration: AircraftConfiguration = AircraftConfiguration(),
        loading: Loading = Loading()
    ) {
        self.id = id
        self.tailNumber = tailNumber
        self.typeName = typeName
        self.configuration = configuration
        self.loading = loading
    }

    /// Creates an aircraft whose configuration is copied from `type`.
    init(tailNumber: String, type: AircraftType) {
        self.init(tailNumber: tailNumber, typeName: type.name, configuration: type.configuration)
    }
}
