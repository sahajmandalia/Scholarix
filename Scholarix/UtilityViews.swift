import SwiftUI

// --- Shared UI Components ---

struct FormRowStyle: ViewModifier {
    var minHeight: CGFloat = 44
    func body(content: Content) -> some View {
        content
            .frame(minHeight: minHeight, alignment: .center)
            .contentShape(Rectangle())
    }
}

extension View {
    func formRow(_ minHeight: CGFloat = 44) -> some View {
        self.modifier(FormRowStyle(minHeight: minHeight))
    }
}

struct header: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 32)) // Slightly smaller icon
                .foregroundColor(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 6)
        .padding(.bottom, 6)
    }
}

struct FormCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Compact spacing
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.bottom, 0)
            
            VStack(spacing: 0) {
                content
                    .padding(8) // Slightly tighter internal padding
            }
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
            .padding(.horizontal)
        }
    }
}

struct FloatingSaveButton: View {
    let label: String
    let isDisabled: Bool
    let isSaving: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Button(action: action) {
                if isSaving {
                    ProgressView().tint(.white)
                        .padding(.vertical, 5)
                } else {
                    Text(label)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                isDisabled ? Color.gray : Color.blue
            )
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            .disabled(isDisabled)
            .padding(.horizontal)
            .padding(.bottom, 6)
        }
        .background(
            LinearGradient(colors: [Color(.systemGroupedBackground).opacity(0), Color(.systemGroupedBackground)], startPoint: .top, endPoint: .bottom)
        )
    }
}
