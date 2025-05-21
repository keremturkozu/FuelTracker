import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HistoryViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    // Filter bar
                    VStack(spacing: 12) {
                        // Fuel type selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                Button {
                                    viewModel.selectedFuelType = nil
                                    viewModel.applyFilters()
                                } label: {
                                    Text("Tümü")
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedFuelType == nil ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(viewModel.selectedFuelType == nil ? .white : .primary)
                                        .cornerRadius(20)
                                }
                                
                                ForEach(viewModel.getUniqueFuelTypes(), id: \.self) { type in
                                    Button {
                                        viewModel.selectedFuelType = type
                                        viewModel.applyFilters()
                                    } label: {
                                        Text(type)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(viewModel.selectedFuelType == type ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(viewModel.selectedFuelType == type ? .white : .primary)
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Divider()
                            .padding(.horizontal)
                    }
                    .background(Color(.systemBackground))
                    
                    if viewModel.filteredEntries.isEmpty {
                        if viewModel.fuelEntries.isEmpty {
                            EmptyStateView(
                                title: "Kayıt Bulunamadı",
                                message: "Yakıt alım kayıtlarınız burada görünecek.",
                                iconName: "list.bullet.clipboard"
                            )
                        } else {
                            VStack(spacing: 20) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("Arama Sonucu Bulunamadı")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Filtrelerinizi değiştirmeyi deneyin.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    } else {
                        List {
                            ForEach(viewModel.filteredEntries) { entry in
                                NavigationLink(destination: EntryDetailView(entry: entry)) {
                                    HistoryEntryRow(entry: entry)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.deleteEntry(entry)
                                    } label: {
                                        Label("Sil", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Geçmiş")
            .searchable(text: $searchText, prompt: "İstasyon, not veya tarih ara")
            .onChange(of: searchText) { _, newValue in
                viewModel.searchText = newValue
                viewModel.applyFilters()
            }
        }
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.fetchEntries()
        }
    }
}

struct HistoryEntryRow: View {
    let entry: FuelEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.formattedDate)
                    .font(.headline)
                
                Spacer()
                
                Text(entry.formattedTotalAmount)
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "fuelpump")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(entry.fuelType) • \(String(format: "%.2f L", entry.liters))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    if !entry.station.isEmpty {
                        HStack {
                            Image(systemName: "mappin.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(entry.station)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if let distance = entry.distance {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(String(format: "%.1f km", distance))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.1f", entry.liters * 100 / distance)) L/100km")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryDetailView: View {
    let entry: FuelEntry
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(entry.formattedDate)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(entry.formattedTotalAmount)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("\(String(format: "%.2f L", entry.liters)) • \(entry.formattedPricePerLiter)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding()
                
                // Details
                VStack(alignment: .leading, spacing: 16) {
                    detailRow(title: "Yakıt Tipi", value: entry.fuelType, iconName: "fuelpump")
                    
                    detailRow(title: "İstasyon", value: entry.station, iconName: "mappin.circle")
                    
                    detailRow(title: "Kilometre", value: String(format: "%.1f km", entry.odometer), iconName: "speedometer")
                    
                    if let distance = entry.distance {
                        detailRow(title: "Mesafe", value: String(format: "%.1f km", distance), iconName: "arrow.left.and.right")
                        
                        detailRow(title: "Yakıt Tüketimi", value: String(format: "%.1f L/100km", entry.liters * 100 / distance), iconName: "drop")
                    }
                    
                    if let notes = entry.notes, !notes.isEmpty {
                        HStack(alignment: .top) {
                            Image(systemName: "note.text")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading) {
                                Text("Notlar")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(notes)
                                    .font(.body)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                .padding(.horizontal)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Kayıt Detayı")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func detailRow(title: String, value: String, iconName: String) -> some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
            }
        }
    }
} 