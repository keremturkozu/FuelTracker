import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FuelPricesView()
                .tabItem {
                    Label("Fiyatlar", systemImage: "fuelpump")
                }
            
            FuelExpensesView()
                .tabItem {
                    Label("Harcamalar", systemImage: "car")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analiz", systemImage: "chart.bar")
                }
            
            HistoryView()
                .tabItem {
                    Label("Geçmiş", systemImage: "clock")
                }
        }
        .accentColor(.blue)
    }
} 
