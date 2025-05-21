import Foundation
import SwiftData

@Model
final class FuelPrice {
    var date: Date
    var type: String
    var price: Double
    var region: String
    
    init(date: Date = Date(), type: String = "", price: Double = 0.0, region: String = "Istanbul") {
        self.date = date
        self.type = type
        self.price = price
        self.region = region
    }
    
    var formattedPrice: String {
        return String(format: "%.2f ₺/L", price)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum FuelType: String, CaseIterable {
    case benzin95 = "Benzin (95)"
    case benzin97 = "Benzin (97)"
    case dizel = "Dizel"
    case eurodizel = "Euro Dizel"
    case lpg = "LPG"
    
    var displayName: String {
        return self.rawValue
    }
} 