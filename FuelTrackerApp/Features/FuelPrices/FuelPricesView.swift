import SwiftUI
import SwiftData

struct FuelPricesView: View {
    @State private var viewModel = FuelPricesViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Region selector
                        Picker("Bölge", selection: $viewModel.selectedRegion) {
                            ForEach(viewModel.regions, id: \.self) { region in
                                Text(region).tag(region)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        // Current prices card
                        CardView(title: "Güncel Yakıt Fiyatları", icon: "fuelpump.fill", color: .blue) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical)
                            } else if let error = viewModel.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding(.vertical)
                            } else {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.currentPrices, id: \.type) { price in
                                        HStack {
                                            Text(price.type)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                            
                                            Text(price.formattedPrice)
                                                .foregroundColor(.blue)
                                                .fontWeight(.bold)
                                        }
                                        .padding(.vertical, 4)
                                        
                                        if viewModel.currentPrices.last?.type != price.type {
                                            Divider()
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Price comparison card
                        CardView(title: "Fiyat Karşılaştırması", icon: "chart.bar.fill", color: .orange) {
                            VStack(spacing: 16) {
                                ForEach(viewModel.currentPrices, id: \.type) { price in
                                    VStack(alignment: .leading) {
                                        Text(price.type)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        
                                        HStack(spacing: 0) {
                                            Rectangle()
                                                .fill(getFuelColor(price.type))
                                                .frame(width: getBarWidth(price), height: 24)
                                                .cornerRadius(4)
                                            
                                            Spacer()
                                        }
                                        
                                        Text(price.formattedPrice)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                        
                        // Last updated info
                        HStack {
                            Spacer()
                            
                            if let firstPrice = viewModel.currentPrices.first {
                                Text("Son güncelleme: \(firstPrice.formattedDate)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Yakıt Fiyatları")
            .refreshable {
                viewModel.fetchCurrentPrices()
            }
        }
        .onAppear {
            viewModel.fetchCurrentPrices()
        }
    }
    
    private func getBarWidth(_ price: FuelPrice) -> CGFloat {
        let maxPrice = viewModel.currentPrices.map { $0.price }.max() ?? 1
        let ratio = price.price / maxPrice
        return UIScreen.main.bounds.width * 0.7 * CGFloat(ratio)
    }
    
    private func getFuelColor(_ type: String) -> Color {
        switch type {
        case FuelType.benzin95.rawValue:
            return .green
        case FuelType.benzin97.rawValue:
            return .blue
        case FuelType.dizel.rawValue:
            return .orange
        case FuelType.eurodizel.rawValue:
            return .purple
        case FuelType.lpg.rawValue:
            return .red
        default:
            return .gray
        }
    }
} 