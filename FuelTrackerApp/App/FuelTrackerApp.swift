import SwiftUI
import SwiftData

@main
struct FuelTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [FuelEntry.self, FuelPrice.self])
    }
} 