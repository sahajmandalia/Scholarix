import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            // --- 1. Background Gradient ---
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                
                // --- 2. Logo & Branding ---
                // Using the custom "AppLogo" asset.
                // If the image doesn't render, check Assets.xcassets to ensure "AppLogo" exists.
                Image("AppLogo")
                    .renderingMode(.template) // Allows recoloring to white
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 10)
                
                Text("Scholarix")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                
                Text("Your all-in-one student OS.\nTrack grades, deadlines, and more.")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // --- 3. Action Buttons ---
                VStack(spacing: 16) {
                    // Log In Button
                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    // Sign Up Button
                    NavigationLink(destination: SignUpView()) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Material.ultraThin) // Glass effect
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
        // Important: Hides the default nav bar so the gradient looks clean
        .navigationBarHidden(true)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WelcomeView()
        }
    }
}
