import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmPasswordError: String? = nil
    @State private var isSigningUp = false

    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 30)
                    
                    // Logo & Welcome
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(Theme.brandPrimary)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(Theme.brandPrimary.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(Theme.brandPrimary.opacity(0.2), lineWidth: 2)
                            )
                        
                        VStack(spacing: 6) {
                            Text("Join Scholarix! 🚀")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.heavy)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Start tracking grades, deadlines, and activities")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
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
                                    .stroke(emailError != nil ? Theme.danger : Theme.borderSubtle, lineWidth: 1)
                            )
                            
                            if let emailError = emailError {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption)
                                    Text(emailError)
                                        .font(.system(.caption, design: .rounded))
                                }
                                .foregroundColor(Theme.danger)
                                .padding(.leading, 4)
                            }
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.brandPrimary)
                                    .frame(width: 24)
                                
                                SecureField("Password (min 6 characters)", text: $password)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.inputBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(passwordError != nil ? Theme.danger : Theme.borderSubtle, lineWidth: 1)
                            )
                            
                            if let passwordError = passwordError {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption)
                                    Text(passwordError)
                                        .font(.system(.caption, design: .rounded))
                                }
                                .foregroundColor(Theme.danger)
                                .padding(.leading, 4)
                            }
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.brandPrimary)
                                    .frame(width: 24)
                                
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.inputBackground)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(confirmPasswordError != nil ? Theme.danger : Theme.borderSubtle, lineWidth: 1)
                            )
                            
                            if let confirmPasswordError = confirmPasswordError {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.caption)
                                    Text(confirmPasswordError)
                                        .font(.system(.caption, design: .rounded))
                                }
                                .foregroundColor(Theme.danger)
                                .padding(.leading, 4)
                            }
                        }
                    }
                    
                    // Sign Up Button
                    Button(action: signUpUser) {
                        HStack(spacing: 8) {
                            if isSigningUp {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Create Account")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 16,
                                style: .continuous
                            ).fill(isSigningUp || email.isEmpty || password.isEmpty ?
                                   AnyShapeStyle(Theme.buttonDisabled) :
                                    AnyShapeStyle(Theme.brandGradient))
                        )
                        .cornerRadius(16)
                        .shadow(
                            color: (isSigningUp || email.isEmpty || password.isEmpty) ? Theme.shadowLight : Theme.brandPrimary.opacity(0.4),
                            radius: 12, x: 0, y: 6
                        )
                    }
                    .disabled(isSigningUp || email.isEmpty || password.isEmpty)
                    .padding(.top, 8)
                    
                    Spacer(minLength: 30)
                    
                    // Login Link
                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        NavigationLink("Log In", destination: LoginView())
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.brandPrimary)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    // --- Validation Logic ---
    func validateForm() -> Bool {
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        var isValid = true
        
        if !email.contains("@") || !email.contains(".") {
            emailError = "Please enter a valid email address."
            isValid = false
        }
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters long."
            isValid = false
        }
        if password != confirmPassword {
            confirmPasswordError = "Passwords do not match."
            isValid = false
        }
        return isValid
    }
    
    // --- Sign Up Logic ---
    func signUpUser() {
        if !validateForm() { return }
        
        isSigningUp = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                isSigningUp = false
                
                if let error = error {
                    let nsError = error as NSError
                    // Handle specific Firebase errors
                    if nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                        self.emailError = "This email is already in use. Please log in."
                    } else if nsError.code == AuthErrorCode.weakPassword.rawValue {
                        self.passwordError = "Password is too weak."
                    } else if nsError.code == AuthErrorCode.invalidEmail.rawValue {
                        self.emailError = "Invalid email address."
                    } else {
                        self.emailError = error.localizedDescription
                    }
                } else {
                    // Success: Send verification email
                    authResult?.user.sendEmailVerification()
                    
                    // ContentView will automatically detect the new user session
                    // and show the VerificationSentView.
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SignUpView()
    }
}
