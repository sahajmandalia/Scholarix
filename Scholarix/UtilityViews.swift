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
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(color)
                .padding(12)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
                .overlay(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
                    .padding(12)
            }
            .background(Theme.cardBackground)
            .cornerRadius(16)
            .shadow(color: Theme.shadowLight, radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.borderSubtle, lineWidth: 0.5)
            )
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
        VStack(spacing: 0) {
            // Gradient fade at top
            LinearGradient(
                colors: [Theme.backgroundGrouped.opacity(0), Theme.backgroundGrouped],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            Button(action: action) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text(label)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isDisabled ? AnyShapeStyle(Theme.buttonDisabled) : AnyShapeStyle(Theme.brandGradient))
                )
                .shadow(color: isDisabled ? Theme.shadowLight : Theme.brandPrimary.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .disabled(isDisabled)
            .padding(.horizontal)
            .padding(.bottom, 12)
            .background(Theme.backgroundGrouped)
        }
    }
}
