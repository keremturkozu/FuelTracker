import Foundation
import SwiftData

@Model
final class FuelEntry {
    var date: Date
    var fuelType: String
    var liters: Double
    var pricePerLiter: Double
    var totalAmount: Double
    var odometer: Double
    var distance: Double?
    var station: String
    var notes: String?
    
    init(date: Date = Date(), 
         fuelType: String = "Benzin", 
         liters: Double = 0.0, 
         pricePerLiter: Double = 0.0, 
         totalAmount: Double = 0.0, 
         odometer: Double = 0.0, 
         distance: Double? = nil, 
         station: String = "", 
         notes: String? = nil) {
        self.date = date
        self.fuelType = fuelType
        self.liters = liters
        self.pricePerLiter = pricePerLiter
        self.totalAmount = totalAmount
        self.odometer = odometer
        self.distance = distance
        self.station = station
        self.notes = notes
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedTotalAmount: String {
        return String(format: "%.2f ₺", totalAmount)
    }
    
    var formattedPricePerLiter: String {
        return String(format: "%.2f ₺/L", pricePerLiter)
    }
} 