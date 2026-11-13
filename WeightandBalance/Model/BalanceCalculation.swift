import Foundation

/// One line of the loading table: an item, its weight and its arm.
struct LoadLine: Hashable, Sendable {
    var name: String
    var weight: Double
    var arm: Double
    var moment: Double { weight * arm }
}

/// Where the loaded CG falls relative to the envelope.
enum EnvelopeStatus: Hashable, Sendable {
    /// Weight and CG are inside (or on the edge of) the envelope.
    case within
    /// Weight and CG are outside the envelope.
    case outside
    /// Fewer than three envelope points, so there is nothing to test against.
    case insufficientEnvelope
    /// Total weight is zero or negative, so the CG is undefined.
    case noWeight

    var description: String {
        switch self {
        case .within: "In balance"
        case .outside: "Out of balance"
        case .insufficientEnvelope: "Envelope needs at least 3 points"
        case .noWeight: "No weight entered"
        }
    }
}

/// The result of a weight-and-balance calculation.
struct BalanceResult: Hashable, Sendable {
    var lines: [LoadLine]
    var totalWeight: Double
    var totalMoment: Double
    var maxGrossWeight: Double
    var envelopeStatus: EnvelopeStatus
    var isFuelWithinCapacity: Bool
    var isBaggageWithinLimit: Bool

    /// Centre of gravity (in), or `nil` when there is no weight.
    var centerOfGravity: Double? {
        totalWeight > 0 ? totalMoment / totalWeight : nil
    }

    var isWithinMaxGross: Bool { totalWeight <= maxGrossWeight }
    var weightOverMaxGross: Double { max(0, totalWeight - maxGrossWeight) }

    /// True only when every check passes.
    var isWithinAllLimits: Bool {
        isWithinMaxGross && isFuelWithinCapacity && isBaggageWithinLimit && envelopeStatus == .within
    }
}

extension Aircraft {
    /// The items that make up the current loading, with weights and arms.
    var loadLines: [LoadLine] {
        let config = configuration
        var lines = [
            LoadLine(name: "Basic empty", weight: config.emptyWeight, arm: config.emptyArm),
            LoadLine(name: "Front row", weight: loading.frontLeft + loading.frontRight, arm: config.frontSeatArm),
            LoadLine(name: "Rear row", weight: loading.rearLeft + loading.rearRight, arm: config.rearSeatArm),
            LoadLine(
                name: "Fuel",
                weight: loading.fuel * AircraftConfiguration.fuelPoundsPerGallon,
                arm: config.fuelArm
            ),
            LoadLine(name: "Baggage", weight: loading.baggage, arm: config.baggageArm),
        ]
        if config.hasTKS {
            lines.append(LoadLine(
                name: "TKS",
                weight: loading.tksFull ? config.tksCapacity * AircraftConfiguration.tksPoundsPerGallon : 0,
                arm: config.tksArm
            ))
        }
        if config.hasOxygen {
            lines.append(LoadLine(
                name: "Oxygen",
                weight: loading.oxygenAboard ? config.oxygenWeight : 0,
                arm: config.oxygenArm
            ))
        }
        return lines
    }

    /// Computes totals, CG and every limit check for the current loading.
    func balance() -> BalanceResult {
        let lines = loadLines
        let totalWeight = lines.reduce(0) { $0 + $1.weight }
        let totalMoment = lines.reduce(0) { $0 + $1.moment }

        let status: EnvelopeStatus
        if configuration.envelope.count < 3 {
            status = .insufficientEnvelope
        } else if totalWeight <= 0 {
            status = .noWeight
        } else {
            let cg = totalMoment / totalWeight
            status = Envelope.contains(arm: cg, weight: totalWeight, in: configuration.envelope) ? .within : .outside
        }

        return BalanceResult(
            lines: lines,
            totalWeight: totalWeight,
            totalMoment: totalMoment,
            maxGrossWeight: configuration.maxGrossWeight,
            envelopeStatus: status,
            isFuelWithinCapacity: loading.fuel <= configuration.fuelCapacity,
            isBaggageWithinLimit: loading.baggage <= configuration.maxBaggageWeight
        )
    }
}

enum Envelope {
    /// Whether the point (arm, weight) lies inside the polygon formed by `points`, or on its edge.
    ///
    /// Uses the non-zero winding rule, matching the `CGPathContainsPoint(..., eoFill: false)` test
    /// the original app used. Points on the boundary count as inside, because envelope limits are
    /// inclusive.
    static func contains(arm: Double, weight: Double, in points: [EnvelopePoint]) -> Bool {
        guard points.count >= 3 else { return false }
        let vertices = points.map { (x: $0.arm, y: $0.weight) }
        let x = arm, y = weight

        // Boundary check, with a tolerance scaled to the size of the numbers involved.
        for i in vertices.indices {
            let a = vertices[i], b = vertices[(i + 1) % vertices.count]
            let scale = max(abs(a.x), abs(a.y), abs(b.x), abs(b.y), 1)
            let cross = (b.x - a.x) * (y - a.y) - (b.y - a.y) * (x - a.x)
            let length = hypot(b.x - a.x, b.y - a.y)
            let withinBox = x >= min(a.x, b.x) - 1e-9 * scale && x <= max(a.x, b.x) + 1e-9 * scale
                && y >= min(a.y, b.y) - 1e-9 * scale && y <= max(a.y, b.y) + 1e-9 * scale
            if withinBox && abs(cross) <= 1e-9 * scale * max(length, 1) {
                return true
            }
        }

        // Winding number.
        var winding = 0
        for i in vertices.indices {
            let a = vertices[i], b = vertices[(i + 1) % vertices.count]
            let side = (b.x - a.x) * (y - a.y) - (x - a.x) * (b.y - a.y)
            if a.y <= y {
                if b.y > y && side > 0 { winding += 1 }
            } else {
                if b.y <= y && side < 0 { winding -= 1 }
            }
        }
        return winding != 0
    }
}
