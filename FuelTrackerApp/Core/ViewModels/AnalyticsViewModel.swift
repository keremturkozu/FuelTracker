import Foundation
import SwiftData
import SwiftUI
import Observation

@Observable
class AnalyticsViewModel {
    var monthlyExpenses: [MonthlyExpense] = []
    var fuelEntries: [FuelEntry] = []
    var selectedTimeFrame: TimeFrame = .month
    var selectedMonth = Calendar.current.component(.month, from: Date())
    var selectedYear = Calendar.current.component(.year, from: Date())
    var errorMessage: String?
    
    var modelContext: ModelContext?
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    func fetchData() {
        guard let context = modelContext else { 
            errorMessage = "Model context not available"
            return 
        }
        
        let descriptor = FetchDescriptor<FuelEntry>(sortBy: [SortDescriptor(\.date, order: .forward)])
        do {
            fuelEntries = try context.fetch(descriptor)
            calculateMonthlyExpenses()
            errorMessage = nil
        } catch {
            errorMessage = "Error fetching data: \(error.localizedDescription)"
            print("Error fetching data for analytics: \(error)")
        }
    }
    
    func calculateMonthlyExpenses() {
        let calendar = Calendar.current
        
        // Group entries by month
        let groupedByMonth = Dictionary(grouping: fuelEntries) { entry in
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }
        
        // Convert to MonthlyExpense objects
        monthlyExpenses = groupedByMonth.map { key, entries in
            let parts = key.split(separator: "-")
            let year = Int(parts[0]) ?? 0
            let month = Int(parts[1]) ?? 0
            
            let totalAmount = entries.reduce(0) { $0 + $1.totalAmount }
            let totalLiters = entries.reduce(0) { $0 + $1.liters }
            let averagePrice = totalLiters > 0 ? totalAmount / totalLiters : 0
            
            var totalDistance: Double = 0
            if let firstEntry = entries.first, 
               let lastEntry = entries.last,
               firstEntry.odometer < lastEntry.odometer {
                totalDistance = lastEntry.odometer - firstEntry.odometer
            }
            
            return MonthlyExpense(
                year: year,
                month: month,
                totalAmount: totalAmount,
                totalLiters: totalLiters,
                averagePricePerLiter: averagePrice,
                totalDistance: totalDistance,
                numberOfEntries: entries.count
            )
        }.sorted { 
            if $0.year != $1.year {
                return $0.year > $1.year
            }
            return $0.month > $1.month
        }
    }
    
    func getDataForSelectedPeriod() -> [FuelEntry] {
        let calendar = Calendar.current
        
        switch selectedTimeFrame {
        case .month:
            return fuelEntries.filter { entry in
                let components = calendar.dateComponents([.year, .month], from: entry.date)
                return components.year == selectedYear && components.month == selectedMonth
            }
        case .year:
            return fuelEntries.filter { entry in
                let components = calendar.dateComponents([.year], from: entry.date)
                return components.year == selectedYear
            }
        case .all:
            return fuelEntries
        }
    }
    
    func getMonthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        return dateFormatter.monthSymbols[month - 1]
    }
}

enum TimeFrame {
    case month, year, all
    
    var displayName: String {
        switch self {
        case .month: return "Aylık"
        case .year: return "Yıllık"
        case .all: return "Tümü"
        }
    }
}

struct MonthlyExpense: Identifiable {
    var id = UUID()
    var year: Int
    var month: Int
    var totalAmount: Double
    var totalLiters: Double
    var averagePricePerLiter: Double
    var totalDistance: Double
    var numberOfEntries: Int
    
    var formattedTotalAmount: String {
        return String(format: "%.2f ₺", totalAmount)
    }
    
    var formattedAveragePrice: String {
        return String(format: "%.2f ₺/L", averagePricePerLiter)
    }
    
    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        return dateFormatter.monthSymbols[month - 1]
    }
    
    var title: String {
        return "\(monthName) \(year)"
    }
} 