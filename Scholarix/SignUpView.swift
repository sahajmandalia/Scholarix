import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    
    // Inputs
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    // Validation
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var confirmPasswordError: String? = nil
    @State private var isSigningUp = false
    
    // Animation States
    @State private var animateGradient = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            // 1. Dynamic Aurora Background
            LinearGradient(
                colors: [
                    Color(hex: "4A00E0"), // Deep Purple
                    Color(hex: "8E2DE2"), // Violet
                    Color(hex: "00C6FF")  // Cyan
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .hueRotation(.degrees(animateGradient ? 45 : 0))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                    showContent = true
                }
            }
            
            // 2. Ambient Circles
            Circle()
                .fill(Color.white.opacity(0.1))
                .blur(radius: 60)
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -250)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)
                    
                    // --- Header ---
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                        
                        Text("Join Scholarix 🚀")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        Text("Track grades, crush deadlines.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .offset(y: showContent ? 0 : -20)
                    .opacity(showContent ? 1 : 0)
                    
                    // --- Glass Form Container ---
                    VStack(spacing: 20) {
                        
                        // Email Input
                        GlassTextField(
                            text: $email,
                            placeholder: "Email Address",
                            icon: "envelope.fill",
                            error: emailError
                        )
                        .keyboardType(.emailAddress)
                        
                        // Password Input
                        GlassSecureField(
                            text: $password,
                            placeholder: "Password (6+ chars)",
                            error: passwordError
                        )
                        
                        // Confirm Password
                        GlassSecureField(
                            text: $confirmPassword,
                            placeholder: "Confirm Password",
                            error: confirmPasswordError
                        )
                        
                        // Sign Up Button
                        Button(action: signUpUser) {
                            HStack {
                                if isSigningUp {
                                    ProgressView()
                                        .tint(Color(hex: "4A00E0"))
                                } else {
                                    Text("Create Account")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                    Image(systemName: "sparkles")
                                }
                            }
                            .foregroundColor(Color(hex: "4A00E0"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isSigningUp)
                        .padding(.top, 10)
                        
                    }
                    .padding(30)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .offset(y: showContent ? 0 : 50)
                    .opacity(showContent ? 1 : 0)
                    
                    // Footer
                    HStack(spacing: 6) {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        NavigationLink(destination: LoginView()) {
                            Text("Log In")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .underline()
                        }
                    }
                    .font(.system(.callout, design: .rounded))
                    .padding(.bottom, 30)
                    .opacity(showContent ? 1 : 0)
                }
            }
        }
        .navigationBarHidden(true)
        .dismissKeyboardOnTap()
    }
    
    // --- Logic ---
    func validateForm() -> Bool {
        emailError = nil; passwordError = nil; confirmPasswordError = nil
        var isValid = true
        
        if !email.contains("@") || !email.contains(".") {
            emailError = "Invalid email"
            isValid = false
        }
        if password.count < 6 {
            passwordError = "Min 6 characters"
            isValid = false
        }
        if password != confirmPassword {
            confirmPasswordError = "Passwords don't match"
            isValid = false
        }
        return isValid
    }
    
    func signUpUser() {
        if !validateForm() { return }
        isSigningUp = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                isSigningUp = false
                if let error = error {
                    // Simple error mapping for demo
                    self.emailError = error.localizedDescription
                } else {
                    authResult?.user.sendEmailVerification()
                }
            }
        }
    }
}

// MARK: - Helper Components for Glass Style

struct GlassTextField: View {
    @Binding var text: String
    var placeholder: String
    var icon: String
    var error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
                
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.5))
                    }
                    .foregroundColor(.white)
                    .autocapitalization(.none)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(error != nil ? Color.red.opacity(0.8) : Color.white.opacity(0.2), lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.9))
                    .padding(.leading, 8)
            }
        }
    }
}

struct GlassSecureField: View {
    @Binding var text: String
    var placeholder: String
    var error: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
                
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder).foregroundColor(.white.opacity(0.5))
                    }
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(error != nil ? Color.red.opacity(0.8) : Color.white.opacity(0.2), lineWidth: 1)
            )
            
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.9))
                    .padding(.leading, 8)
            }
        }
    }
}
