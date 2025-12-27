import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // Inputs
    @State private var email = ""
    @State private var password = ""
    
    // State
    @State private var emailError: String? = nil
    @State private var passwordError: String? = nil
    @State private var isLoggingIn = false
    
    // Animation
    @State private var animateGradient = false
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // 1. Dynamic Aurora Background
            LinearGradient(
                colors: [
                    Color(hex: "4A00E0"),
                    Color(hex: "8E2DE2"),
                    Color(hex: "00C6FF")
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
                .fill(Color.blue.opacity(0.2))
                .blur(radius: 80)
                .frame(width: 400, height: 400)
                .offset(x: 100, y: 300)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer(minLength: 60)
                    
                    // --- Header ---
                    VStack(spacing: 16) {
                        Image("AppLogo")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                        
                        Text("Welcome Back 👋")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        Text("Let's get you back on track")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .offset(y: showContent ? 0 : -20)
                    .opacity(showContent ? 1 : 0)
                    
                    // --- Glass Form Container ---
                    VStack(spacing: 20) {
                        
                        // Email
                        GlassTextField(
                            text: $email,
                            placeholder: "Email Address",
                            icon: "envelope.fill",
                            error: emailError
                        )
                        .keyboardType(.emailAddress)
                        
                        // Password
                        GlassSecureField(
                            text: $password,
                            placeholder: "Password",
                            error: passwordError
                        )
                        
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            NavigationLink(destination: ForgotPasswordView()) {
                                Text("Forgot Password?")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
                        // Login Button
                        Button(action: logInUser) {
                            HStack {
                                if isLoggingIn {
                                    ProgressView()
                                        .tint(Color(hex: "4A00E0"))
                                } else {
                                    Text("Log In")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .foregroundColor(Color(hex: "4A00E0"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoggingIn)
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
                        Text("Don't have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
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
    
    func logInUser() {
        emailError = nil; passwordError = nil
        isLoggingIn = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                isLoggingIn = false
                if let error = error {
                    self.emailError = "Invalid email or password"
                    print("Login error: \(error.localizedDescription)")
                } else {
                    print("Login successful")
                }
            }
        }
    }
}
