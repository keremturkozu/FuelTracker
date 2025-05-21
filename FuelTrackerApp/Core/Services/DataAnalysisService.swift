import Foundation

class DataAnalysisService {
    func validateEntries(_ entries: [FuelEntry]) -> [String] {
        var issues: [String] = []
        for entry in entries {
            if entry.liters <= 0 { issues.append("Tarih: \(entry.formattedDate) - Litre bilgisi eksik veya hatalı.") }
            if entry.pricePerLiter <= 0 { issues.append("Tarih: \(entry.formattedDate) - Litre fiyatı eksik veya hatalı.") }
            if entry.odometer < 0 { issues.append("Tarih: \(entry.formattedDate) - Kilometre bilgisi eksik veya hatalı.") }
            if let distance = entry.distance, distance < 0 {
                issues.append("Tarih: \(entry.formattedDate) - Mesafe negatif olamaz.")
            }
        }
        let outlierEntries = detectOutliers(entries)
        for entry in outlierEntries {
            issues.append("Tarih: \(entry.formattedDate) - Olağan dışı tüketim değeri tespit edildi.")
        }
        return issues
    }
    
    func generateReport(_ entries: [FuelEntry]) -> String {
        guard !entries.isEmpty else { return "Kayıt bulunamadı." }
        let total = entries.reduce(0) { $0 + $1.totalAmount }
        let avg = total / Double(entries.count)
        let totalLiters = entries.reduce(0) { $0 + $1.liters }
        let avgConsumption = entries.compactMap { entry -> Double? in
            guard let distance = entry.distance, distance > 0 else { return nil }
            return (entry.liters * 100) / distance
        }
        let avgCons = avgConsumption.isEmpty ? 0 : avgConsumption.reduce(0, +) / Double(avgConsumption.count)
        let maxCons = avgConsumption.max() ?? 0
        let minCons = avgConsumption.min() ?? 0
        return "Toplam Harcama: \(String(format: "%.2f", total)) ₺\nOrtalama Harcama: \(String(format: "%.2f", avg)) ₺\nToplam Litre: \(String(format: "%.2f", totalLiters)) L\nOrtalama Tüketim: \(String(format: "%.2f", avgCons)) L/100km\nMaksimum Tüketim: \(String(format: "%.2f", maxCons)) L/100km\nMinimum Tüketim: \(String(format: "%.2f", minCons)) L/100km"
    }
    
    private func detectOutliers(_ entries: [FuelEntry]) -> [FuelEntry] {
        let consumptions = entries.compactMap { entry -> Double? in
            guard let distance = entry.distance, distance > 0 else { return nil }
            return (entry.liters * 100) / distance
        }
        guard consumptions.count > 2 else { return [] }
        let mean = consumptions.reduce(0, +) / Double(consumptions.count)
        let std = sqrt(consumptions.map { pow($0 - mean, 2) }.reduce(0, +) / Double(consumptions.count))
        let threshold = 2.0
        return entries.filter { entry in
            guard let distance = entry.distance, distance > 0 else { return false }
            let cons = (entry.liters * 100) / distance
            return abs(cons - mean) > threshold * std
        }
    }
} 