import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class FuelExpensesViewModel {
    var fuelEntries: [FuelEntry] = []
    var newEntry = FuelEntry()
    var isShowingAddForm = false
    var previousOdometer: Double?
    
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func saveEntry() {
        // Calculate total if not entered
        if newEntry.totalAmount == 0 {
            newEntry.totalAmount = newEntry.liters * newEntry.pricePerLiter
        }
        
        // Calculate distance if we have previous odometer reading
        if let previous = previousOdometer {
            newEntry.distance = newEntry.odometer - previous
        }
        
        if let context = modelContext {
            context.insert(newEntry)
            do {
                try context.save()
                fetchEntries()
                resetForm()
            } catch {
                print("Error saving entry: \(error)")
            }
        }
    }
    
    func fetchEntries() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<FuelEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        do {
            fuelEntries = try context.fetch(descriptor)
            if let lastEntry = fuelEntries.first {
                previousOdometer = lastEntry.odometer
            }
        } catch {
            print("Error fetching entries: \(error)")
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
    
    func resetForm() {
        newEntry = FuelEntry()
        if let previous = previousOdometer {
            newEntry.odometer = previous
        }
        isShowingAddForm = false
    }
} 