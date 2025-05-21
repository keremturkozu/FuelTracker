import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
class HistoryViewModel {
    var fuelEntries: [FuelEntry] = []
    var filteredEntries: [FuelEntry] = []
    var searchText: String = ""
    var selectedFuelType: String?
    
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func fetchEntries() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<FuelEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            fuelEntries = try context.fetch(descriptor)
            applyFilters()
        } catch {
            print("Error fetching history entries: \(error)")
        }
    }
    
    func applyFilters() {
        filteredEntries = fuelEntries
        
        // Apply fuel type filter
        if let fuelType = selectedFuelType, !fuelType.isEmpty {
            filteredEntries = filteredEntries.filter { $0.fuelType == fuelType }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            filteredEntries = filteredEntries.filter { entry in
                entry.station.localizedCaseInsensitiveContains(searchText) ||
                (entry.notes?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                entry.formattedDate.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func deleteEntry(_ entry: FuelEntry) {
        guard let context = modelContext else { return }
        
        context.delete(entry)
        do {
            try context.save()
            fetchEntries()
        } catch {
            print("Error deleting entry: \(error)")
        }
    }
    
    func getUniqueFuelTypes() -> [String] {
        let types = Set(fuelEntries.map { $0.fuelType })
        return Array(types).sorted()
    }
} 