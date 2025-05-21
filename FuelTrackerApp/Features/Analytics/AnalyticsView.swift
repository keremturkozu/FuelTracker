import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AnalyticsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.fuelEntries.isEmpty {
                    EmptyStateView(
                        title: "Analiz İçin Veri Bulunamadı",
                        message: "Analiz görüntülemek için önce yakıt alım verisi eklemelisiniz.",
                        iconName: "chart.bar.xaxis"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Time selector
                            Picker("Zaman Aralığı", selection: $viewModel.selectedTimeFrame) {
                                ForEach([TimeFrame.month, TimeFrame.year, TimeFrame.all], id: \.self) { timeFrame in
                                    Text(timeFrame.displayName).tag(timeFrame)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if viewModel.selectedTimeFrame == .month {
                                HStack {
                                    Picker("Ay", selection: $viewModel.selectedMonth) {
                                        ForEach(1...12, id: \.self) { month in
                                            Text(viewModel.getMonthName(month)).tag(month)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Picker("Yıl", selection: $viewModel.selectedYear) {
                                        ForEach(Array(Set(viewModel.monthlyExpenses.map { $0.year })).sorted().reversed(), id: \.self) { year in
                                            Text("\(year)").tag(year)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            } else if viewModel.selectedTimeFrame == .year {
                                Picker("Yıl", selection: $viewModel.selectedYear) {
                                    ForEach(Array(Set(viewModel.monthlyExpenses.map { $0.year })).sorted().reversed(), id: \.self) { year in
                                        Text("\(year)").tag(year)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                            }
                            
                            let selectedData = viewModel.getDataForSelectedPeriod()
                            
                            // Total expenses card
                            CardView(title: "Toplam Harcama", icon: "turkishlirasign.circle.fill", color: .green) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(String(format: "%.2f ₺", selectedData.reduce(0) { $0 + $1.totalAmount }))
                                        .font(.system(size: 28, weight: .bold))
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Toplam: \(String(format: "%.2f L", selectedData.reduce(0) { $0 + $1.liters })) Litre")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        Text("Kayıt: \(selectedData.count) adet")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Monthly expense chart
                            if viewModel.selectedTimeFrame != .month && !viewModel.monthlyExpenses.isEmpty {
                                CardView(title: "Aylık Harcama Grafiği", icon: "chart.bar.fill", color: .blue) {
                                    let filteredExpenses = viewModel.selectedTimeFrame == .year 
                                        ? viewModel.monthlyExpenses.filter { $0.year == viewModel.selectedYear }
                                        : viewModel.monthlyExpenses
                                    
                                    Chart(filteredExpenses.sorted { 
                                        if $0.year != $1.year {
                                            return $0.year < $1.year
                                        }
                                        return $0.month < $1.month
                                    }) { expense in
                                        BarMark(
                                            x: .value("Ay", "\(expense.monthName.prefix(3))"),
                                            y: .value("Harcama", expense.totalAmount)
                                        )
                                        .foregroundStyle(Color.blue.gradient)
                                        .annotation(position: .top) {
                                            Text("\(Int(expense.totalAmount))₺")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading)
                                    }
                                    .frame(height: 220)
                                    .padding(.top)
                                }
                            }
                            
                            // Fuel consumption chart
                            if selectedData.count > 1 {
                                CardView(title: "Yakıt Tüketimi", icon: "fuelpump.fill", color: .orange) {
                                    let entriesWithConsumption = selectedData.filter { $0.distance != nil }
                                    
                                    if entriesWithConsumption.count > 1 {
                                        Chart(entriesWithConsumption.sorted { $0.date < $1.date }) { entry in
                                            LineMark(
                                                x: .value("Tarih", entry.date),
                                                y: .value("Tüketim", (entry.liters * 100) / (entry.distance ?? 1))
                                            )
                                            .foregroundStyle(Color.orange.gradient)
                                            .interpolationMethod(.catmullRom)
                                            
                                            PointMark(
                                                x: .value("Tarih", entry.date),
                                                y: .value("Tüketim", (entry.liters * 100) / (entry.distance ?? 1))
                                            )
                                            .foregroundStyle(Color.orange)
                                        }
                                        .chartYAxis {
                                            AxisMarks(position: .leading) { value in
                                                let doubleValue = value.as(Double.self) ?? 0
                                                AxisValueLabel {
                                                    Text("\(String(format: "%.1f", doubleValue))")
                                                }
                                                AxisGridLine()
                                            }
                                        }
                                        .chartYAxisLabel("L/100km")
                                        .frame(height: 220)
                                        .padding(.top)
                                    } else {
                                        Text("Tüketim verisi için en az iki kayıt gerekli")
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding()
                                    }
                                }
                                
                                // Fuel price chart
                                CardView(title: "Yakıt Fiyatı Değişimi", icon: "chart.line.uptrend.xyaxis", color: .purple) {
                                    Chart(selectedData.sorted { $0.date < $1.date }) { entry in
                                        LineMark(
                                            x: .value("Tarih", entry.date),
                                            y: .value("Fiyat", entry.pricePerLiter)
                                        )
                                        .foregroundStyle(Color.purple.gradient)
                                        .interpolationMethod(.catmullRom)
                                        
                                        PointMark(
                                            x: .value("Tarih", entry.date),
                                            y: .value("Fiyat", entry.pricePerLiter)
                                        )
                                        .foregroundStyle(Color.purple)
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { value in
                                            let doubleValue = value.as(Double.self) ?? 0
                                            AxisValueLabel {
                                                Text("\(String(format: "%.1f ₺", doubleValue))")
                                            }
                                            AxisGridLine()
                                        }
                                    }
                                    .frame(height: 220)
                                    .padding(.top)
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Analiz")
        }
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.fetchData()
        }
        .onChange(of: viewModel.selectedTimeFrame) { _, _ in
            viewModel.fetchData()
        }
        .onChange(of: viewModel.selectedMonth) { _, _ in
            viewModel.fetchData()
        }
        .onChange(of: viewModel.selectedYear) { _, _ in
            viewModel.fetchData()
        }
    }
} 