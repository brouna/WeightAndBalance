import SwiftUI

enum Route: Hashable {
    case aircraft(Aircraft.ID)
    case types
    case type(AircraftType.ID)
}

/// The root screen: the user's aircraft.
struct AircraftListView: View {
    @Environment(Library.self) private var library
    @State private var path: [Route] = []
    @State private var isAddingAircraft = false
    @State private var isShowingSaveError = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(library.aircraft) { aircraft in
                    NavigationLink(value: Route.aircraft(aircraft.id)) {
                        AircraftRow(aircraft: aircraft)
                    }
                }
                .onDelete { library.deleteAircraft(at: $0) }
                .onMove { library.moveAircraft(from: $0, to: $1) }
            }
            .overlay {
                if library.aircraft.isEmpty {
                    ContentUnavailableView {
                        Label("No Aircraft", systemImage: "airplane")
                    } description: {
                        Text("Add an aircraft to start calculating weight and balance.")
                    } actions: {
                        Button("Add Aircraft") { isAddingAircraft = true }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Aircraft")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if !library.aircraft.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Aircraft", systemImage: "plus") { isAddingAircraft = true }
                }
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(value: Route.types) {
                        Label("Aircraft Types", systemImage: "list.bullet.rectangle")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .navigationDestination(for: Route.self) { destination(for: $0) }
            .sheet(isPresented: $isAddingAircraft) {
                NewAircraftView { aircraft in
                    path.append(.aircraft(aircraft.id))
                }
            }
        }
        .onChange(of: library.saveError) { _, error in
            isShowingSaveError = error != nil
        }
        .alert("Couldn't Save Changes", isPresented: $isShowingSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(library.saveError ?? "")
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .aircraft(let id):
            if let aircraft = library.aircraft.first(where: { $0.id == id }) {
                AircraftScreen(aircraft: aircraft)
                    .id(id)
            } else {
                ContentUnavailableView("Aircraft Not Found", systemImage: "airplane")
            }
        case .types:
            TypeListView(path: $path)
        case .type(let id):
            if let type = library.types.first(where: { $0.id == id }) {
                TypeEditView(type: type)
                    .id(id)
            } else {
                ContentUnavailableView("Type Not Found", systemImage: "list.bullet.rectangle")
            }
        }
    }
}

private struct AircraftRow: View {
    let aircraft: Aircraft

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(aircraft.tailNumber.isEmpty ? "Untitled" : aircraft.tailNumber)
                .font(.headline)
            if !aircraft.typeName.isEmpty {
                Text(aircraft.typeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AircraftListView()
        .environment(Library.preview)
}
