import SwiftUI

/// Loads an aircraft and shows whether it is within limits. Edits are written back to the library.
struct AircraftScreen: View {
    @Environment(Library.self) private var library
    @State private var aircraft: Aircraft
    @State private var isEditing = false
    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case frontLeft, frontRight, rearLeft, rearRight, fuel, baggage
    }

    init(aircraft: Aircraft) {
        _aircraft = State(initialValue: aircraft)
    }

    var body: some View {
        let result = aircraft.balance()
        let config = aircraft.configuration

        Form {
            Section {
                EnvelopeChart(
                    envelope: config.envelope,
                    loading: result.centerOfGravity.map { (arm: $0, weight: result.totalWeight) },
                    loadingIsWithinLimits: result.isWithinAllLimits
                )
                .padding(.vertical, 8)

                LimitRow(
                    title: "Envelope",
                    detail: result.envelopeStatus.description,
                    isOK: result.envelopeStatus == .within
                )
                LimitRow(
                    title: "Gross weight",
                    detail: result.isWithinMaxGross
                        ? "\(pounds(result.totalWeight)) of \(pounds(result.maxGrossWeight))"
                        : "\(pounds(result.weightOverMaxGross)) over maximum",
                    isOK: result.isWithinMaxGross
                )
                if !result.isFuelWithinCapacity {
                    LimitRow(title: "Fuel", detail: "More than \(gallons(config.fuelCapacity)) capacity", isOK: false)
                }
                if !result.isBaggageWithinLimit {
                    LimitRow(title: "Baggage", detail: "More than \(pounds(config.maxBaggageWeight)) limit", isOK: false)
                }
                LabeledContent("CG", value: result.centerOfGravity.map(inches) ?? "—")
                LabeledContent("Moment/1000", value: (result.totalMoment / 1000).formatted(.number.precision(.fractionLength(1))))
            } header: {
                Text("Result")
            }

            Section("Front Row") {
                NumberField(title: "Left", value: $aircraft.loading.frontLeft, unit: "lb", focus: $focus, focusID: .frontLeft)
                NumberField(title: "Right", value: $aircraft.loading.frontRight, unit: "lb", focus: $focus, focusID: .frontRight)
            }

            Section("Rear Row") {
                NumberField(title: "Left", value: $aircraft.loading.rearLeft, unit: "lb", focus: $focus, focusID: .rearLeft)
                NumberField(title: "Right", value: $aircraft.loading.rearRight, unit: "lb", focus: $focus, focusID: .rearRight)
            }

            Section {
                NumberField(title: "Fuel", value: $aircraft.loading.fuel, unit: "gal", focus: $focus, focusID: .fuel)
                NumberField(title: "Baggage", value: $aircraft.loading.baggage, unit: "lb", focus: $focus, focusID: .baggage)
                if config.hasTKS {
                    Toggle("TKS tank full", isOn: $aircraft.loading.tksFull)
                }
                if config.hasOxygen {
                    Toggle("Oxygen aboard", isOn: $aircraft.loading.oxygenAboard)
                }
            } header: {
                Text("Fuel and Baggage")
            } footer: {
                Text("Fuel capacity \(gallons(config.fuelCapacity)) at 6 lb/gal. Baggage limit \(pounds(config.maxBaggageWeight)).")
            }

            Section {
                ForEach(result.lines, id: \.name) { line in
                    LabeledContent(line.name) {
                        Text("\(pounds(line.weight)) at \(inches(line.arm))")
                            .monospacedDigit()
                    }
                }
                LabeledContent("Total") {
                    Text(pounds(result.totalWeight))
                        .monospacedDigit()
                        .bold()
                }
            } header: {
                Text("Breakdown")
            } footer: {
                Text("For planning only. Always confirm weight and balance against the aircraft's POH and current weight and balance records.")
            }
        }
        .navigationTitle(aircraft.tailNumber.isEmpty ? "Untitled" : aircraft.tailNumber)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ShareLink(
                    item: aircraft.loadReport(),
                    subject: Text("Weight and balance for \(aircraft.tailNumber)")
                ) {
                    Label("Share Loading", systemImage: "square.and.arrow.up")
                }
                Button("Edit") { isEditing = true }
            }
        }
        .keyboardDoneButton($focus)
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                AircraftEditView(aircraft: $aircraft)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { isEditing = false }
                        }
                    }
            }
        }
        .onChange(of: aircraft) { _, updated in
            library.update(updated)
        }
    }
}

/// A row showing whether one limit is met, using both colour and an icon.
struct LimitRow: View {
    let title: LocalizedStringKey
    let detail: String
    let isOK: Bool

    var body: some View {
        LabeledContent {
            Text(detail)
                .foregroundStyle(isOK ? Color.secondary : Color.red)
        } label: {
            Label {
                Text(title)
            } icon: {
                Image(systemName: isOK ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isOK ? Color.green : Color.red)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Formatting

func pounds(_ value: Double) -> String {
    "\(value.formatted(.number.precision(.fractionLength(0...1)))) lb"
}

func inches(_ value: Double) -> String {
    "\(value.formatted(.number.precision(.fractionLength(1)))) in"
}

func gallons(_ value: Double) -> String {
    "\(value.formatted(.number.precision(.fractionLength(0...1)))) gal"
}

#Preview {
    NavigationStack {
        AircraftScreen(aircraft: Library.preview.aircraft[0])
    }
    .environment(Library.preview)
}
