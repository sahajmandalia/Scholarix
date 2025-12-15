import SwiftUI
import FirebaseAuth
import Combine

struct VerificationSentView: View {
    let email: String
    
    // We need access to the SessionManager to update the user state instantly
    @EnvironmentObject var sessionManager: SessionManager
    
    // --- State for Feedback ---
    @State private var resendMessage: String? = nil
    @State private var isResending = false
    
    // --- Cooldown State ---
    @State private var timeRemaining = 0
    let cooldownTime = 30
    
    // --- Timers ---
    // Timer 1: Checks for verification every 2 seconds
    let verificationTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    // Timer 2: Handles the countdown for the button
    let cooldownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Success Icon with Animation
                Image(systemName: "envelope.open.fill")
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(Theme.success)
                    .padding(24)
                    .background(
                        Circle()
                            .fill(Theme.success.opacity(0.1))
                    )
                    .overlay(
                        Circle()
                            .stroke(Theme.success.opacity(0.3), lineWidth: 3)
                    )
                
                VStack(spacing: 10) {
                    Text("Check Your Email! 📧")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        Text("We've sent a verification email to")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        Text(email)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.brandPrimary)
                        Text("Click the link to activate your account")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                }
                
                // Auto-update notice
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                    Text("This screen will update automatically")
                        .font(.system(.caption, design: .rounded))
                }
                .foregroundColor(Theme.textTertiary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.cardBackground)
                .cornerRadius(8)
                
                // Resend Feedback
                if let message = resendMessage {
                    HStack(spacing: 8) {
                        Image(systemName: message.contains("Success") ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .font(.callout)
                        Text(message)
                            .font(.system(.callout, design: .rounded))
                    }
                    .foregroundColor(message.contains("Success") ? Theme.success : Theme.danger)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        (message.contains("Success") ? Theme.success : Theme.danger).opacity(0.1)
                    )
                    .cornerRadius(12)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    // Resend Button
                    Button(action: resendVerificationEmail) {
                        HStack(spacing: 8) {
                            if isResending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.brandPrimary))
                                    .scaleEffect(0.9)
                            } else if timeRemaining > 0 {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Resend in \(timeRemaining)s")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Resend Email")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                        }
                        .foregroundColor(isResending || timeRemaining > 0 ? Theme.textSecondary : Theme.brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Theme.cardBackground)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Theme.borderSubtle, lineWidth: 1)
                        )
                    }
                    .disabled(isResending || timeRemaining > 0)
                    
                    // Return to Login
                    Button(action: { try? Auth.auth().signOut() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Return to Login")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.brandGradient)
                        .cornerRadius(16)
                        .shadow(color: Theme.brandPrimary.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        
        // --- TIMER 1: Auto-Check Verification ---
        .onReceive(verificationTimer) { _ in
            checkVerificationStatus()
        }
        
        // --- TIMER 2: Cooldown Countdown ---
        .onReceive(cooldownTimer) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    // --- Logic to check if verified ---
    private func checkVerificationStatus() {
        // We must reload the user to get the latest 'isEmailVerified' status from Firebase
        Auth.auth().currentUser?.reload { error in
            if error == nil {
                if let user = Auth.auth().currentUser, user.isEmailVerified {
                    // If verified, update the SessionManager.
                    // This triggers ContentView to switch to the Main App instantly.
                    sessionManager.user = user
                }
            }
        }
    }
    
    // --- Logic to resend email ---
    private func resendVerificationEmail() {
        guard timeRemaining == 0 else { return }
        
        isResending = true
        resendMessage = nil
        
        Auth.auth().currentUser?.sendEmailVerification() { error in
            DispatchQueue.main.async {
                isResending = false
                if let error = error {
                    self.resendMessage = "Error: \(error.localizedDescription)"
                } else {
                    self.resendMessage = "Success! Email sent."
                    self.timeRemaining = cooldownTime // Start cooldown
                }
            }
        }
    }
}

#Preview {
    // We need a SessionManager for the preview
    VerificationSentView(email: "test@example.com")
        .environmentObject(SessionManager())
}
