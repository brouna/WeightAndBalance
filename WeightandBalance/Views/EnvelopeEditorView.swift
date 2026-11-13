import SwiftUI

/// Edits the points of a CG envelope, in the order they are joined.
struct EnvelopeEditorView: View {
    @Binding var envelope: [EnvelopePoint]
    var maxGrossWeight: Double

    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case weight(EnvelopePoint.ID)
        case arm(EnvelopePoint.ID)
    }

    var body: some View {
        Form {
            Section {
                EnvelopeChart(envelope: envelope)
                    .padding(.vertical, 8)
            }

            Section {
                ForEach($envelope) { $point in
                    VStack(alignment: .leading, spacing: 4) {
                        NumberField(title: "Weight", value: $point.weight, unit: "lb",
                                    focus: $focus, focusID: .weight(point.id))
                        NumberField(title: "Arm", value: $point.arm, unit: "in", allowsNegative: true,
                                    focus: $focus, focusID: .arm(point.id))
                        if maxGrossWeight > 0 && point.weight > maxGrossWeight {
                            Label("Above max gross weight", systemImage: "exclamationmark.triangle.fill")
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onDelete { offsets in
                    focus = nil
                    envelope.remove(atOffsets: offsets)
                }
                .onMove { source, destination in
                    envelope.move(fromOffsets: source, toOffset: destination)
                }

                Button("Add Point", systemImage: "plus") {
                    let point = EnvelopePoint(weight: 0, arm: 0)
                    envelope.append(point)
                    focus = .weight(point.id)
                }
            } header: {
                Text("Points")
            } footer: {
                Text("Enter the corners of the CG envelope from the POH, going around the outline in order. The last point joins back to the first.")
            }
        }
        .navigationTitle("CG Envelope")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
        .keyboardDoneButton($focus)
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    @Previewable @State var envelope = Library.preview.types[0].configuration.envelope
    NavigationStack {
        EnvelopeEditorView(envelope: $envelope, maxGrossWeight: 3400)
    }
}
