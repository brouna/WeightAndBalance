import SwiftUI

/// Focusable fields on the aircraft and type editors.
enum ConfigurationField: Hashable {
    case name, typeName
    case emptyWeight, emptyArm
    case frontSeatArm, rearSeatArm
    case fuelCapacity, fuelArm
    case maxBaggageWeight, baggageArm
    case maxGrossWeight
    case tksCapacity, tksArm
    case oxygenWeight, oxygenArm
}

/// Form sections for editing an `AircraftConfiguration`; shared by the aircraft and type editors.
struct ConfigurationSections: View {
    @Binding var configuration: AircraftConfiguration
    let focus: FocusState<ConfigurationField?>.Binding

    var body: some View {
        Section("Basic Empty Weight") {
            field("Weight", \.emptyWeight, unit: "lb", .emptyWeight)
            field("Arm", \.emptyArm, unit: "in", .emptyArm, allowsNegative: true)
        }

        Section("Seats") {
            field("Front row arm", \.frontSeatArm, unit: "in", .frontSeatArm, allowsNegative: true)
            field("Rear row arm", \.rearSeatArm, unit: "in", .rearSeatArm, allowsNegative: true)
        }

        Section("Fuel") {
            field("Usable capacity", \.fuelCapacity, unit: "gal", .fuelCapacity)
            field("Arm", \.fuelArm, unit: "in", .fuelArm, allowsNegative: true)
        }

        Section("Baggage") {
            field("Maximum", \.maxBaggageWeight, unit: "lb", .maxBaggageWeight)
            field("Arm", \.baggageArm, unit: "in", .baggageArm, allowsNegative: true)
        }

        Section("Limits") {
            field("Max gross weight", \.maxGrossWeight, unit: "lb", .maxGrossWeight)
            NavigationLink {
                EnvelopeEditorView(
                    envelope: $configuration.envelope,
                    maxGrossWeight: configuration.maxGrossWeight
                )
            } label: {
                LabeledContent("CG envelope", value: "\(configuration.envelope.count) points")
            }
        }

        Section {
            field("Capacity", \.tksCapacity, unit: "gal", .tksCapacity)
            field("Arm", \.tksArm, unit: "in", .tksArm, allowsNegative: true)
        } header: {
            Text("TKS De-Ice")
        } footer: {
            Text("Leave capacity blank if not installed. TKS fluid weighs 9.1 lb/gal.")
        }

        Section {
            field("Weight", \.oxygenWeight, unit: "lb", .oxygenWeight)
            field("Arm", \.oxygenArm, unit: "in", .oxygenArm, allowsNegative: true)
        } header: {
            Text("Oxygen")
        } footer: {
            Text("Leave weight blank if no oxygen system is carried.")
        }
    }

    private func field(
        _ title: LocalizedStringKey,
        _ keyPath: WritableKeyPath<AircraftConfiguration, Double>,
        unit: String,
        _ id: ConfigurationField,
        allowsNegative: Bool = false
    ) -> some View {
        NumberField(
            title: title,
            value: $configuration[dynamicMember: keyPath],
            unit: unit,
            allowsNegative: allowsNegative,
            focus: focus,
            focusID: id
        )
    }
}

/// Edits an aircraft's identity and configuration.
struct AircraftEditView: View {
    @Binding var aircraft: Aircraft
    @FocusState private var focus: ConfigurationField?

    var body: some View {
        Form {
            Section("Aircraft") {
                LabeledContent("Tail number") {
                    TextField("N12345", text: $aircraft.tailNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.trailing)
                        .focused($focus, equals: .name)
                }
                LabeledContent("Type") {
                    TextField("SR22", text: $aircraft.typeName)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.trailing)
                        .focused($focus, equals: .typeName)
                }
            }
            ConfigurationSections(configuration: $aircraft.configuration, focus: $focus)
        }
        .navigationTitle("Edit \(aircraft.tailNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton($focus)
        .scrollDismissesKeyboard(.interactively)
    }
}

/// Edits an aircraft type. Changes are written back to the library.
struct TypeEditView: View {
    @Environment(Library.self) private var library
    @State private var type: AircraftType
    @FocusState private var focus: ConfigurationField?

    init(type: AircraftType) {
        _type = State(initialValue: type)
    }

    var body: some View {
        Form {
            Section {
                LabeledContent("Name") {
                    TextField("e.g. SR22", text: $type.name)
                        .autocorrectionDisabled()
                        .multilineTextAlignment(.trailing)
                        .focused($focus, equals: .name)
                }
            } footer: {
                Text("Changes apply to aircraft created from this type later, not to existing aircraft.")
            }
            ConfigurationSections(configuration: $type.configuration, focus: $focus)
        }
        .navigationTitle(type.name.isEmpty ? "New Type" : type.name)
        .navigationBarTitleDisplayMode(.inline)
        .keyboardDoneButton($focus)
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: type) { _, updated in
            library.update(updated)
        }
    }
}

#Preview("Aircraft") {
    @Previewable @State var aircraft = Library.preview.aircraft[0]
    NavigationStack {
        AircraftEditView(aircraft: $aircraft)
    }
}
