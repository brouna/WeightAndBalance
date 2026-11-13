import SwiftUI

/// Manages the aircraft types used as templates for new aircraft.
struct TypeListView: View {
    @Environment(Library.self) private var library
    @Binding var path: [Route]

    var body: some View {
        List {
            Section {
                ForEach(library.types) { type in
                    NavigationLink(value: Route.type(type.id)) {
                        Text(type.name.isEmpty ? "Untitled Type" : type.name)
                    }
                }
                .onDelete { library.deleteTypes(at: $0) }
                .onMove { library.moveTypes(from: $0, to: $1) }
            } footer: {
                Text("Types are templates. Adding an aircraft copies a type's weights, arms and envelope.")
            }
        }
        .overlay {
            if library.types.isEmpty {
                ContentUnavailableView(
                    "No Aircraft Types",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Add a type to use as a template for new aircraft.")
                )
            }
        }
        .navigationTitle("Aircraft Types")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Add Type", systemImage: "plus") {
                    let type = library.addType()
                    path.append(.type(type.id))
                }
                if !library.types.isEmpty {
                    EditButton()
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var path: [Route] = []
    NavigationStack {
        TypeListView(path: $path)
    }
    .environment(Library.preview)
}
