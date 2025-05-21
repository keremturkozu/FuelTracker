import Foundation
import SwiftUI
import SwiftData
import Observation

@Observable
class FuelPricesViewModel {
    var currentPrices: [FuelPrice] = []
    var isLoading = false
    var errorMessage: String?
    var selectedRegion = "Istanbul"
    
    let regions = ["Istanbul", "Ankara", "Izmir", "Antalya", "Bursa"]
    
    func fetchCurrentPrices() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currentPrices = [
                FuelPrice(date: Date(), type: FuelType.benzin95.rawValue, price: 38.76, region: self.selectedRegion),
                FuelPrice(date: Date(), type: FuelType.benzin97.rawValue, price: 41.85, region: self.selectedRegion),
                FuelPrice(date: Date(), type: FuelType.dizel.rawValue, price: 37.94, region: self.selectedRegion),
                FuelPrice(date: Date(), type: FuelType.eurodizel.rawValue, price: 38.52, region: self.selectedRegion),
                FuelPrice(date: Date(), type: FuelType.lpg.rawValue, price: 16.28, region: self.selectedRegion)
            ]
            self.isLoading = false
        }
    }
    
    func changeRegion(_ region: String) {
        selectedRegion = region
        fetchCurrentPrices()
    }
} 