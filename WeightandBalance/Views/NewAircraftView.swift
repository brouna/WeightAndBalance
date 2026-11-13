import SwiftUI

/// Sheet for adding an aircraft, optionally starting from an aircraft type.
struct NewAircraftView: View {
    @Environment(Library.self) private var library
    @Environment(\.dismiss) private var dismiss

    /// Called with the new aircraft after it has been added to the library.
    let onCreate: (Aircraft) -> Void

    @State private var tailNumber = ""
    @State private var selectedTypeID: AircraftType.ID?

    private var trimmedTailNumber: String {
        tailNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tail Number") {
                    TextField("N12345", text: $tailNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .onSubmit(add)
                }

                Section {
                    Picker("Aircraft Type", selection: $selectedTypeID) {
                        Text("Blank").tag(AircraftType.ID?.none)
                        ForEach(library.types) { type in
                            Text(type.name.isEmpty ? "Untitled Type" : type.name)
                                .tag(Optional(type.id))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Start From")
                } footer: {
                    Text("The aircraft gets its own copy of the type's weights, arms and envelope. Update them from your aircraft's weight and balance records.")
                }
            }
            .navigationTitle("New Aircraft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .disabled(trimmedTailNumber.isEmpty)
                }
            }
        }
    }

    private func add() {
        guard !trimmedTailNumber.isEmpty else { return }
        let type = library.types.first { $0.id == selectedTypeID }
        let aircraft = library.addAircraft(tailNumber: trimmedTailNumber, type: type)
        dismiss()
        onCreate(aircraft)
    }
}

#Preview {
    NewAircraftView { _ in }
        .environment(Library.preview)
}
