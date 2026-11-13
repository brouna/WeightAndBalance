import SwiftUI

/// A labelled numeric text field that writes to a `Double` as the user types.
///
/// Uses the user's locale for the decimal separator. Arms can be negative (aft of a forward datum),
/// so those fields use a keyboard with a minus key.
struct NumberField<FocusID: Hashable>: View {
    let title: LocalizedStringKey
    @Binding var value: Double
    var unit: String?
    var allowsNegative = false
    let focus: FocusState<FocusID?>.Binding
    let focusID: FocusID

    @State private var text = ""

    var body: some View {
        LabeledContent {
            HStack(spacing: 4) {
                TextField("0", text: $text)
                    .keyboardType(allowsNegative ? .numbersAndPunctuation : .decimalPad)
                    .multilineTextAlignment(.trailing)
                    .focused(focus, equals: focusID)
                    .submitLabel(.done)
                if let unit {
                    Text(unit)
                        .foregroundStyle(.secondary)
                }
            }
        } label: {
            Text(title)
        }
        .onAppear { text = Self.format(value) }
        .onChange(of: text) { _, newText in
            let parsed = Self.parse(newText, allowsNegative: allowsNegative)
            if let parsed, parsed != value {
                value = parsed
            }
        }
        .onChange(of: value) { _, newValue in
            // Reflect changes made elsewhere, without fighting the user while they type.
            if focus.wrappedValue != focusID, Self.parse(text, allowsNegative: allowsNegative) != newValue {
                text = Self.format(newValue)
            }
        }
        .onChange(of: focus.wrappedValue) { _, newFocus in
            if newFocus != focusID {
                text = Self.format(value)
            }
        }
    }

    static func format(_ value: Double) -> String {
        value == 0 ? "" : value.formatted(.number.precision(.fractionLength(0...2)).grouping(.never))
    }

    /// Empty text means zero. Returns `nil` for text that isn't (yet) a number, such as "-".
    static func parse(_ text: String, allowsNegative: Bool) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return 0 }
        guard let number = try? Double(trimmed, format: .number) else { return nil }
        return allowsNegative ? number : abs(number)
    }
}

/// Adds a Done button above the keyboard, since number pads have no return key.
struct KeyboardDoneToolbar<FocusID: Hashable>: ViewModifier {
    let focus: FocusState<FocusID?>.Binding

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focus.wrappedValue = nil }
            }
        }
    }
}

extension View {
    func keyboardDoneButton<FocusID: Hashable>(_ focus: FocusState<FocusID?>.Binding) -> some View {
        modifier(KeyboardDoneToolbar(focus: focus))
    }
}
