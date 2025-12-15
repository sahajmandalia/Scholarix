import SwiftUI

struct PrivacyAgreementView: View {
    @AppStorage("hasAgreedToPrivacy") var hasAgreedToPrivacy: Bool = false
    @State private var isChecked = false
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Privacy Icon
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 70, weight: .medium))
                    .foregroundColor(Theme.brandPrimary)
                    .padding(24)
                    .background(
                        Circle()
                            .fill(Theme.brandPrimary.opacity(0.1))
                    )
                    .overlay(
                        Circle()
                            .stroke(Theme.brandPrimary.opacity(0.2), lineWidth: 2)
                    )
                
                VStack(spacing: 10) {
                    Text("Privacy & Terms 🔒")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text("Before you start using Scholarix, please review and agree to our Privacy Policy")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                
                // Policy Link Card
                Link(destination: URL(string: "https://www.sites.google.com/scholarixapp/legal")!) {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Read Privacy Policy")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Theme.brandPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Theme.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Theme.brandPrimary.opacity(0.3), lineWidth: 2)
                    )
                    .shadow(color: Theme.shadowLight, radius: 6, x: 0, y: 2)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Checkbox
                Button(action: { isChecked.toggle() }) {
                    HStack(spacing: 12) {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(isChecked ? Theme.success : Theme.textSecondary)
                        Text("I agree to the Privacy Policy")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(Theme.textPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(isChecked ? Theme.success.opacity(0.1) : Theme.cardBackground)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isChecked ? Theme.success : Theme.borderSubtle, lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 30)
                
                // Continue Button
                Button(action: {
                    if isChecked {
                        hasAgreedToPrivacy = true
                    } else {
                        showingAlert = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Continue to Scholarix")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        isChecked ? Theme.brandGradient : LinearGradient(
                            colors: [Theme.buttonDisabled, Theme.buttonDisabled],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(
                        color: isChecked ? Theme.brandPrimary.opacity(0.4) : Theme.shadowLight,
                        radius: 12, x: 0, y: 6
                    )
                }
                .disabled(!isChecked)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .alert("Agreement Required", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You must agree to the Privacy Policy to continue.")
        }
    }
}
