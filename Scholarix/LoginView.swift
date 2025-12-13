import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    // --- Error States ---
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    
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
            
            Text("Scholarix")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
            
            Text("Welcome Back.")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // --- Inputs ---
            VStack(alignment: .leading) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let emailError = emailError {
                    Text(emailError).foregroundColor(.red).font(.caption)
                }
            }

            VStack(alignment: .leading) {
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                if let passwordError = passwordError {
                    Text(passwordError).foregroundColor(.red).font(.caption)
                }
            }
            
            // --- Forgot Password ---
            HStack {
                Spacer()
                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Forgot Password?")
                        .font(.callout)
                        .foregroundColor(.blue)
                }
            }

            // --- Login Button ---
            Button(action: logInUser) {
                Text("Log In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
            
            // --- Sign Up Link ---
            HStack {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                NavigationLink("Sign Up", destination: SignUpView())
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    // --- Logic ---
    func logInUser() {
        emailError = nil
        passwordError = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    let nsError = error as NSError
                    
                    // Handle specific Firebase errors
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
