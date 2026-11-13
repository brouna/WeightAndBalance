import SwiftUI

@main
struct WeightAndBalanceApp: App {
    @State private var library = Library(storage: .standard())
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            AircraftListView()
                .environment(library)
                .onAppear {
                    // Persist migrated or default data immediately so it is only converted once.
                    library.save()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active {
                library.save()
            }
        }
    }
}
