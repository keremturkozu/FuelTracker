import SwiftUI

struct CardView<Content: View>: View {
    var title: String
    var icon: String? = nil
    var color: Color = .blue
    @ViewBuilder var content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.bottom, 4)
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

struct PrimaryButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    var color: Color = .blue
    var fullWidth: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

struct SectionHeader: View {
    var title: String
    var iconName: String? = nil
    
    var body: some View {
        HStack {
            if let icon = iconName {
                Image(systemName: icon)
                    .foregroundColor(.blue)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

struct EmptyStateView: View {
    var title: String
    var message: String
    var iconName: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
} 