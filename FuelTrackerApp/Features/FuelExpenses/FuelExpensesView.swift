import SwiftUI
import SwiftData

struct FuelExpensesView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = FuelExpensesViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.fuelEntries.isEmpty {
                    EmptyStateView(
                        title: "Yakıt Harcaması Bulunamadı",
                        message: "İlk yakıt alım kaydınızı eklemek için + butonuna tıklayın.",
                        iconName: "fuelpump.circle"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Last entry summary
                            if let lastEntry = viewModel.fuelEntries.first {
                                CardView(title: "Son Yakıt Alımı", icon: "calendar", color: .blue) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text(lastEntry.formattedDate)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text(lastEntry.fuelType)
                                                .font(.subheadline)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(8)
                                        }
                                        
                                        Divider()
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Toplam")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(lastEntry.formattedTotalAmount)
                                                    .font(.headline)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading) {
                                                Text("Litre")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(String(format: "%.2f L", lastEntry.liters))
                                                    .font(.headline)
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .leading) {
                                                Text("Litre Fiyatı")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(lastEntry.formattedPricePerLiter)
                                                    .font(.headline)
                                            }
                                        }
                                        
                                        if let distance = lastEntry.distance {
                                            Divider()
                                            
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text("Kilometre")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Text(String(format: "%.1f km", lastEntry.odometer))
                                                        .font(.headline)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .leading) {
                                                    Text("Mesafe")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Text(String(format: "%.1f km", distance))
                                                        .font(.headline)
                                                }
                                                
                                                Spacer()
                                                
                                                VStack(alignment: .leading) {
                                                    Text("Tüketim")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                    
                                                    Text(String(format: "%.1f L/100km", lastEntry.liters * 100 / distance))
                                                        .font(.headline)
                                                }
                                            }
                                        }
                                        
                                        if let notes = lastEntry.notes, !notes.isEmpty {
                                            Divider()
                                            
                                            Text("Not: \(notes)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                                .padding(.top)
                            }
                            
                            // Recent entries
                            SectionHeader(title: "Son Kayıtlar", iconName: "list.bullet")
                            
                            ForEach(Array(viewModel.fuelEntries.prefix(5))) { entry in
                                EntryListItem(entry: entry) {
                                    viewModel.deleteEntry(entry)
                                }
                            }
                            
                            if viewModel.fuelEntries.count > 5 {
                                NavigationLink(destination: HistoryView()) {
                                    Text("Tüm Kayıtları Gör")
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Yakıt Harcamaları")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.isShowingAddForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingAddForm) {
                AddFuelEntryView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.fetchEntries()
        }
    }
}

struct EntryListItem: View {
    let entry: FuelEntry
    let onDelete: () -> Void
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Text("\(entry.station) • \(entry.fuelType)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(entry.formattedTotalAmount)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(String(format: "%.2f L", entry.liters))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .padding(.horizontal)
            .swipeActions {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Sil", systemImage: "trash")
                }
            }
        }
    }
}

struct AddFuelEntryView: View {
    @Environment(\.dismiss) private var dismiss
    var viewModel: FuelExpensesViewModel
    @State private var date: Date
    @State private var fuelType: String
    @State private var station: String
    @State private var liters: Double
    @State private var pricePerLiter: Double
    @State private var totalAmount: Double
    @State private var odometer: Double
    @State private var notes: String
    
    init(viewModel: FuelExpensesViewModel) {
        self.viewModel = viewModel
        _date = State(initialValue: viewModel.newEntry.date)
        _fuelType = State(initialValue: viewModel.newEntry.fuelType)
        _station = State(initialValue: viewModel.newEntry.station)
        _liters = State(initialValue: viewModel.newEntry.liters)
        _pricePerLiter = State(initialValue: viewModel.newEntry.pricePerLiter)
        _totalAmount = State(initialValue: viewModel.newEntry.totalAmount)
        _odometer = State(initialValue: viewModel.newEntry.odometer)
        _notes = State(initialValue: viewModel.newEntry.notes ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Temel Bilgiler")) {
                    DatePicker("Tarih", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Yakıt Tipi", selection: $fuelType) {
                        ForEach(FuelType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                    
                    TextField("İstasyon", text: $station)
                }
                
                Section(header: Text("Miktar ve Tutar")) {
                    HStack {
                        Text("Litre")
                        Spacer()
                        TextField("0.00", value: $liters, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: liters) { _, newValue in
                                totalAmount = newValue * pricePerLiter
                            }
                    }
                    
                    HStack {
                        Text("Litre Fiyatı (₺)")
                        Spacer()
                        TextField("0.00", value: $pricePerLiter, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: pricePerLiter) { _, newValue in
                                totalAmount = liters * newValue
                            }
                    }
                    
                    HStack {
                        Text("Toplam Tutar (₺)")
                        Spacer()
                        TextField("0.00", value: $totalAmount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Araç Bilgileri")) {
                    HStack {
                        Text("Kilometre")
                        Spacer()
                        TextField("0", value: $odometer, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let previous = viewModel.previousOdometer {
                        HStack {
                            Text("Önceki Kilometre")
                            Spacer()
                            Text(String(format: "%.1f km", previous))
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Mesafe")
                            Spacer()
                            Text(String(format: "%.1f km", odometer - previous))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Notlar")) {
                    TextField("Not", text: $notes)
                }
            }
            .navigationTitle("Yeni Kayıt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        // Değerleri viewModel'e aktarıyoruz
                        viewModel.newEntry.date = date
                        viewModel.newEntry.fuelType = fuelType
                        viewModel.newEntry.station = station
                        viewModel.newEntry.liters = liters
                        viewModel.newEntry.pricePerLiter = pricePerLiter
                        viewModel.newEntry.totalAmount = totalAmount
                        viewModel.newEntry.odometer = odometer
                        viewModel.newEntry.notes = notes.isEmpty ? nil : notes
                        
                        viewModel.saveEntry()
                        dismiss()
                    }
                }
            }
        }
    }
} 