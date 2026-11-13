import Foundation

extension Aircraft {
    /// A plain-text record of the current loading, for sharing or keeping with flight records.
    func loadReport(date: Date = .now, locale: Locale = .current) -> String {
        let result = balance()
        func number(_ value: Double) -> String {
            value.formatted(.number.precision(.fractionLength(1)).locale(locale))
        }

        var text = """
        Weight and Balance
        ==================
        \(typeName) \(tailNumber)
        Calculated \(date.formatted(Date.FormatStyle(date: .complete, time: .shortened).locale(locale)))


        """

        for line in result.lines {
            text += "\(line.name): \(number(line.weight)) lb at \(number(line.arm)) in\n"
        }

        text += "\n"
        text += "Total weight: \(number(result.totalWeight)) lb (max \(number(result.maxGrossWeight)) lb)\n"
        if let cg = result.centerOfGravity {
            text += "CG: \(number(cg)) in\n"
        }
        text += "Moment/1000: \(number(result.totalMoment / 1000))\n\n"

        text += "Envelope: \(result.envelopeStatus.description)\n"
        if !result.isWithinMaxGross {
            text += "Over max gross weight by \(number(result.weightOverMaxGross)) lb\n"
        }
        if !result.isFuelWithinCapacity {
            text += "Fuel exceeds capacity of \(number(configuration.fuelCapacity)) gal\n"
        }
        if !result.isBaggageWithinLimit {
            text += "Baggage exceeds limit of \(number(configuration.maxBaggageWeight)) lb\n"
        }
        text += result.isWithinAllLimits ? "Result: within all limits\n" : "Result: NOT within limits\n"
        return text
    }
}
