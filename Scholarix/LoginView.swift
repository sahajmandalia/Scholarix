import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    
    var body: some View {
        ZStack {
            // Background
            Theme.backgroundGrouped.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // Logo & Welcome Message
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
                            Text("Welcome Back! 👋")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.heavy)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Let's get you back on track")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Input Fields
                    VStack(spacing: 16) {
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Theme.brandPrimary)
                                    .frame(width: 24)
                                
                                SecureField("Password", text: $password)
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
                    }
                    
                    // Forgot Password
                    HStack {
                        Spacer()
                        NavigationLink(destination: ForgotPasswordView()) {
                            Text("Forgot Password?")
                                .font(.system(.callout, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.brandPrimary)
                        }
                    }
                    .padding(.top, -8)
                    
                    // Login Button
                    Button(action: logInUser) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Log In")
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
                    .padding(.top, 8)
                    
                    Spacer(minLength: 40)
                    
                    // Sign Up Link
                    HStack(spacing: 6) {
                        Text("Don't have an account?")
                            .font(.system(.callout, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        NavigationLink("Sign Up", destination: SignUpView())
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
    
    func logInUser() {
        emailError = nil
        passwordError = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    
                    if nsError.code == AuthErrorCode.wrongPassword.rawValue ||
                       nsError.code == AuthErrorCode.userNotFound.rawValue ||
                       nsError.code == AuthErrorCode.invalidEmail.rawValue {
                        self.emailError = "Invalid email or password."
                    } else {
                        self.emailError = error.localizedDescription
                    }
                } else {
                    print("Login successful")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        LoginView()
    }
}
