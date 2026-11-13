import Foundation

/// Reads the `NSKeyedArchiver` files written by the Objective-C versions of the app (1.x–3.x)
/// and converts them to the current model types.
///
/// The archives reference the Objective-C class names `Aircraft`, `AircraftType`, `Datum` and
/// `EnvelopePoint`; those names are mapped onto the private `Legacy*` classes below.
enum LegacyArchive {
    enum ReadError: Error {
        case unexpectedContents
    }

    /// Decodes an archive of aircraft (the old `aircraft.archive`).
    static func decodeAircraft(from data: Data) throws -> [Aircraft] {
        let objects = try decodeRoot(data, elementClass: LegacyAircraft.self)
        return objects.map(\.converted)
    }

    /// Decodes an archive of aircraft types (the old `types.v2.archive`).
    static func decodeTypes(from data: Data) throws -> [AircraftType] {
        let objects = try decodeRoot(data, elementClass: LegacyAircraftType.self)
        return objects.map(\.converted)
    }

    private static func decodeRoot<T: NSObject>(_ data: Data, elementClass: T.Type) throws -> [T] {
        let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
        unarchiver.requiresSecureCoding = true
        unarchiver.decodingFailurePolicy = .setErrorAndReturn
        unarchiver.setClass(LegacyAircraft.self, forClassName: "Aircraft")
        unarchiver.setClass(LegacyAircraftType.self, forClassName: "AircraftType")
        unarchiver.setClass(LegacyDatum.self, forClassName: "Datum")
        unarchiver.setClass(LegacyEnvelopePoint.self, forClassName: "EnvelopePoint")
        defer { unarchiver.finishDecoding() }

        let root = unarchiver.decodeObject(
            of: [NSArray.self, NSMutableArray.self, elementClass],
            forKey: NSKeyedArchiveRootObjectKey
        )
        if let error = unarchiver.error { throw error }
        guard let array = root as? NSArray else { throw ReadError.unexpectedContents }
        return array.compactMap { $0 as? T }
    }
}

// MARK: - Number clean-up

/// The old app stored most values as 32-bit floats, so 137.8 was archived as 137.8000030517578.
/// When a value is exactly representable as a `Float`, converting through `Float`'s shortest
/// decimal representation recovers the value the user typed. Other values are used unchanged.
func cleanLegacyDouble(_ number: NSNumber?) -> Double {
    guard let number else { return 0 }
    let value = number.doubleValue
    let asFloat = Float(value)
    guard asFloat.isFinite, Double(asFloat) == value else { return value }
    return Double(String(asFloat)) ?? value
}

// MARK: - Decoding helpers

private let numberClasses: [AnyClass] = [NSNumber.self]
private let stringClasses: [AnyClass] = [NSString.self, NSMutableString.self]

private extension NSCoder {
    func legacyNumber(_ key: String) -> Double {
        cleanLegacyDouble(decodeObject(of: numberClasses, forKey: key) as? NSNumber)
    }

    func legacyString(_ key: String) -> String {
        (decodeObject(of: stringClasses, forKey: key) as? NSString).map { String($0) } ?? ""
    }

    func legacyEnvelope() -> [EnvelopePoint] {
        let object = decodeObject(
            of: [NSArray.self, NSMutableArray.self, LegacyEnvelopePoint.self],
            forKey: "envelope"
        )
        guard let array = object as? NSArray else { return [] }
        return array.compactMap { ($0 as? LegacyEnvelopePoint)?.converted }
    }

    func legacyDatums() -> [String: LegacyDatum] {
        let object = decodeObject(
            of: [NSDictionary.self, NSMutableDictionary.self, NSString.self, NSMutableString.self, LegacyDatum.self],
            forKey: "datums"
        )
        guard let dictionary = object as? NSDictionary else { return [:] }
        var result: [String: LegacyDatum] = [:]
        for (key, value) in dictionary {
            if let key = key as? NSString, let datum = value as? LegacyDatum {
                result[String(key)] = datum
            }
        }
        return result
    }
}

/// The fields shared by the old `Aircraft` and `AircraftType` classes.
private struct LegacyConfigurationFields {
    var maxGross: Double
    var maxFuel: Double
    var maxBaggage: Double
    var maxTKS: Double
    var maxO2: Double
    var frontArm: Double
    var backArm: Double
    var datums: [String: LegacyDatum]
    var envelope: [EnvelopePoint]

    init(coder: NSCoder) {
        maxGross = coder.legacyNumber("maxGross")
        maxFuel = coder.legacyNumber("maxFuel")
        maxBaggage = coder.legacyNumber("maxBaggage")
        maxTKS = coder.legacyNumber("MaxTKS")
        maxO2 = coder.legacyNumber("MaxO2")
        frontArm = coder.legacyNumber("frontArm")
        backArm = coder.legacyNumber("backArm")
        datums = coder.legacyDatums()
        envelope = coder.legacyEnvelope()
    }

    var configuration: AircraftConfiguration {
        AircraftConfiguration(
            emptyWeight: datums["Basic Empty"]?.quantity ?? 0,
            emptyArm: datums["Basic Empty"]?.arm ?? 0,
            frontSeatArm: frontArm,
            rearSeatArm: backArm,
            fuelCapacity: maxFuel,
            fuelArm: datums["Fuel"]?.arm ?? 0,
            maxBaggageWeight: maxBaggage,
            baggageArm: datums["Baggage"]?.arm ?? 0,
            tksCapacity: maxTKS,
            tksArm: datums["TKS"]?.arm ?? 0,
            oxygenWeight: maxO2,
            oxygenArm: datums["Oxygen"]?.arm ?? 0,
            maxGrossWeight: maxGross,
            envelope: envelope
        )
    }
}

// MARK: - Legacy classes

private final class LegacyDatum: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    let name: String
    let quantity: Double
    let weightPerQuantity: Double
    let arm: Double

    init?(coder: NSCoder) {
        name = coder.legacyString("DatumName")
        quantity = coder.legacyNumber("DatumQuantity")
        weightPerQuantity = coder.legacyNumber("DatumWPQ")
        arm = coder.legacyNumber("DatumArm")
    }

    func encode(with coder: NSCoder) {
        // Legacy archives are read-only.
    }
}

private final class LegacyEnvelopePoint: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    let weight: Double
    let arm: Double

    init?(coder: NSCoder) {
        weight = coder.legacyNumber("EWeight")
        arm = coder.legacyNumber("EArm")
    }

    func encode(with coder: NSCoder) {}

    var converted: EnvelopePoint { EnvelopePoint(weight: weight, arm: arm) }
}

private final class LegacyAircraftType: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    let typeName: String
    let fields: LegacyConfigurationFields

    init?(coder: NSCoder) {
        typeName = coder.legacyString("typeName")
        fields = LegacyConfigurationFields(coder: coder)
    }

    func encode(with coder: NSCoder) {}

    var converted: AircraftType {
        AircraftType(name: typeName, configuration: fields.configuration)
    }
}

private final class LegacyAircraft: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool { true }

    let tailNumber: String
    let typeName: String
    let fields: LegacyConfigurationFields
    let pilot: Double
    let coPilot: Double
    let rearLeft: Double
    let rearRight: Double

    init?(coder: NSCoder) {
        tailNumber = coder.legacyString("tailNumber")
        typeName = coder.legacyString("typeName")
        fields = LegacyConfigurationFields(coder: coder)
        pilot = coder.legacyNumber("pilotWt")
        coPilot = coder.legacyNumber("coPilotWt")
        rearLeft = coder.legacyNumber("secRowLeftWt")
        rearRight = coder.legacyNumber("secRowRightWt")
    }

    func encode(with coder: NSCoder) {}

    var converted: Aircraft {
        let datums = fields.datums
        let loading = Loading(
            frontLeft: pilot,
            frontRight: coPilot,
            rearLeft: rearLeft,
            rearRight: rearRight,
            baggage: datums["Baggage"]?.quantity ?? 0,
            fuel: datums["Fuel"]?.quantity ?? 0,
            tksFull: (datums["TKS"]?.quantity ?? 0) > 0,
            oxygenAboard: (datums["Oxygen"]?.quantity ?? 0) > 0
        )
        return Aircraft(
            tailNumber: tailNumber,
            typeName: typeName,
            configuration: fields.configuration,
            loading: loading
        )
    }
}
