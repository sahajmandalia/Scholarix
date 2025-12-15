import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    Spacer(minLength: 40)
                    
                    // Icon
                    Image(systemName: "lock.rotation")
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
                    
                    VStack(spacing: 8) {
                        Text("Reset Password 🔐")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text("No worries! Enter your email and we'll send you a link to reset your password")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // Email Input
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Theme.brandPrimary)
                                .frame(width: 24)
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Theme.textPrimary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Theme.inputBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Theme.borderSubtle, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Send Reset Button
                    Button(action: sendPasswordReset) {
                        HStack(spacing: 8) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Send Reset Link")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AnyShapeStyle(Theme.brandGradient))
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: email.isEmpty ? Theme.shadowLight : Theme.brandPrimary.opacity(0.4),
                            radius: 12, x: 0, y: 6
                        )
                    }
                    .disabled(email.isEmpty)
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(isSuccess ? "Check your Email 📧" : "Oops!"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
        .dismissKeyboardOnTap()
    }
    
    private func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
                isSuccess = false
            } else {
                alertMessage = "We have sent a password reset link to \(email)."
                isSuccess = true
            }
            showAlert = true
        }
    }
}

#Preview {
    ForgotPasswordView()
}
