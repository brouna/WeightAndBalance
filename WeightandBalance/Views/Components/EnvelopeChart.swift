import Charts
import SwiftUI

/// Draws the CG envelope and, optionally, the current loading as a point.
struct EnvelopeChart: View {
    var envelope: [EnvelopePoint]
    /// The loaded weight and CG, if there is one to show.
    var loading: (arm: Double, weight: Double)?
    var loadingIsWithinLimits = true

    var body: some View {
        if envelope.count < 3 {
            ContentUnavailableView(
                "No Envelope",
                systemImage: "chart.xyaxis.line",
                description: Text("Add at least three envelope points to see the CG chart.")
            )
        } else {
            chart
        }
    }

    private var chart: some View {
        // Repeat the first point so the outline closes.
        let outline = Array((envelope + [envelope[0]]).enumerated())
        return Chart {
            ForEach(outline, id: \.offset) { _, point in
                LineMark(
                    x: .value("Arm", point.arm),
                    y: .value("Weight", point.weight),
                    series: .value("Series", "Envelope")
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            if let loading {
                PointMark(x: .value("Arm", loading.arm), y: .value("Weight", loading.weight))
                    .symbol(.cross)
                    .symbolSize(180)
                    .foregroundStyle(loadingIsWithinLimits ? Color.green : Color.red)
                    .accessibilityLabel("Current loading")
                    .accessibilityValue(
                        "\(loading.weight.formatted(.number.precision(.fractionLength(0)))) pounds at "
                            + "\(loading.arm.formatted(.number.precision(.fractionLength(1)))) inches, "
                            + (loadingIsWithinLimits ? "within limits" : "outside limits")
                    )
            }
        }
        .chartXScale(domain: domain(\.arm, extra: loading?.arm))
        .chartYScale(domain: domain(\.weight, extra: loading?.weight))
        .chartXAxisLabel("Arm (in)")
        .chartYAxisLabel("Weight (lb)")
        .frame(minHeight: 220)
    }

    /// The range of the envelope (and loading point), padded so nothing sits on the chart's edge.
    private func domain(_ keyPath: KeyPath<EnvelopePoint, Double>, extra: Double?) -> ClosedRange<Double> {
        var values = envelope.map { $0[keyPath: keyPath] }
        if let extra, extra.isFinite { values.append(extra) }
        let low = values.min() ?? 0
        let high = values.max() ?? 1
        let padding = max((high - low) * 0.08, 1)
        return (low - padding)...(high + padding)
    }
}

#Preview {
    EnvelopeChart(
        envelope: [
            EnvelopePoint(weight: 2100, arm: 137.8),
            EnvelopePoint(weight: 2700, arm: 139.1),
            EnvelopePoint(weight: 3400, arm: 142.3),
            EnvelopePoint(weight: 3400, arm: 148.1),
            EnvelopePoint(weight: 2100, arm: 148.1),
        ],
        loading: (arm: 143.9, weight: 3340)
    )
    .padding()
}
