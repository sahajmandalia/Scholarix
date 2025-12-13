import SwiftUI

struct WelcomeView: View {
    // Add this to access the guest flag
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        ZStack {
            // ... Background & Logo ...
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Spacer()
                // ... Logo Code ...
                Image("AppLogo")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.bottom, 10)
                
                Text("Scholarix")
                    .font(.system(size: 40, weight: .heavy, design: .default))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("Your all-in-one student OS.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: LoginView()) {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    
                    NavigationLink(destination: SignUpView()) {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}
