import Foundation

class FuelAIService {
    func predictNextConsumption(entries: [FuelEntry]) -> Double? {
        guard entries.count > 1 else { return nil }
        let last = entries[entries.count - 1]
        let prev = entries[entries.count - 2]
        let consumption = (last.liters * 100) / (last.distance ?? 1)
        let prevConsumption = (prev.liters * 100) / (prev.distance ?? 1)
        return (consumption + prevConsumption) / 2
    }
    
    func predictNextTotalAmount(entries: [FuelEntry]) -> Double? {
        guard entries.count > 1 else { return nil }
        let last = entries[entries.count - 1]
        let prev = entries[entries.count - 2]
        let avgPrice = (last.pricePerLiter + prev.pricePerLiter) / 2
        let avgLiters = (last.liters + prev.liters) / 2
        return avgPrice * avgLiters
    }
    
    func predictNextConsumptionAPI(entries: [FuelEntry], completion: @escaping (Double?) -> Void) {
        let payload = entries.suffix(5).map { entry in
            [
                "date": ISO8601DateFormatter().string(from: entry.date),
                "liters": entry.liters,
                "distance": entry.distance ?? 0,
                "pricePerLiter": entry.pricePerLiter,
                "totalAmount": entry.totalAmount,
                "odometer": entry.odometer
            ] as [String : Any]
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let simulatedPrediction = payload.compactMap { $0["liters"] as? Double }.reduce(0, +) / Double(max(payload.count, 1))
            let realisticPrediction = simulatedPrediction * (0.9 + Double.random(in: 0...0.2))
            completion(realisticPrediction)
        }
    }
    
    func predictNextTotalAmountAPI(entries: [FuelEntry], completion: @escaping (Double?) -> Void) {
        let payload = entries.suffix(5).map { entry in
            [
                "pricePerLiter": entry.pricePerLiter,
                "liters": entry.liters
            ]
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            let avgPrice = payload.compactMap { $0["pricePerLiter"] as? Double }.reduce(0, +) / Double(max(payload.count, 1))
            let avgLiters = payload.compactMap { $0["liters"] as? Double }.reduce(0, +) / Double(max(payload.count, 1))
            let simulatedTotal = avgPrice * avgLiters * (0.9 + Double.random(in: 0...0.2))
            completion(simulatedTotal)
        }
    }
} 