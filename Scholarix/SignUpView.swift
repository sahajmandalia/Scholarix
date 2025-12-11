import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Error States
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmPasswordError: String? = nil
    
    @State private var isSigningUp = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // --- Logo ---
            Image("AppLogo") // Ensure this matches your asset name
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
            
            Text("Start tracking your grades and schedule today.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            // --- Inputs ---
            VStack(alignment: .leading, spacing: 5) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let emailError = emailError {
                    Text(emailError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 5)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                SecureField("Password (min 6 characters)", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let passwordError = passwordError {
                    Text(passwordError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 5)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let confirmPasswordError = confirmPasswordError {
                    Text(confirmPasswordError)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.leading, 5)
                }
            }

            // --- Sign Up Button ---
            Button(action: signUpUser) {
                if isSigningUp {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.vertical, 5)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
            .disabled(isSigningUp || email.isEmpty || password.isEmpty)
            .padding(.top, 10)
            
            Spacer()
            
            // --- Navigation to Login ---
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                NavigationLink("Log In", destination: LoginView())
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 30)
        .navigationBarHidden(true)
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
