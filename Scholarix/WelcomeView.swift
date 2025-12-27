import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var animateGradient = false
    @State private var floatLogo = false
    
    var body: some View {
        ZStack {
            // 1. Modern "Aurora" Background
            // A deep, rich background that shifts slowly
            LinearGradient(
                colors: [
                    Color(hex: "4A00E0"), // Deep Purple
                    Color(hex: "8E2DE2"), // Violet
                    Color(hex: "00C6FF")  // Cyan/Blue
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
            }
            
            // 2. Ambient Floating Orbs (Subtle)
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .blur(radius: 60)
                        .frame(width: 300, height: 300)
                        .offset(x: -100, y: -200)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .blur(radius: 80)
                        .frame(width: 400, height: 400)
                        .offset(x: 200, y: 300)
                }
            }
            
            // 3. Main Content
            VStack(spacing: 0) {
                Spacer()
                
                // --- Glass Card Content ---
                VStack(spacing: 24) {
                    // Floating Logo
                    Image("AppLogo") // Ensure this asset exists, or use system image
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 20, x: 0, y: 0)
                        .offset(y: floatLogo ? -10 : 10)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                                floatLogo.toggle()
                            }
                        }
                    
                    VStack(spacing: 8) {
                        // Gradient Text Mask
                        Text("Scholarix")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .overlay(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.7)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .mask(
                                    Text("Scholarix")
                                        .font(.system(size: 42, weight: .black, design: .rounded))
                                )
                            )
                            // Fallback if mask is tricky, just make it white:
                            .foregroundColor(.clear)
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        
                        Text("The OS for your Academic Life")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .tracking(0.5)
                    }
                    
                    Text("Track grades, manage deadlines, and balance your wellness—all in one place.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .lineLimit(3)
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .background(
                    .ultraThinMaterial, // The "Frosted Glass" effect
                    in: RoundedRectangle(cornerRadius: 30, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                
                Spacer()
                
                // --- Action Buttons ---
                VStack(spacing: 20) {
                    // Primary CTA
                    NavigationLink(destination: SignUpView()) {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "4A00E0"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    }
                    
                    // Secondary CTA
                    NavigationLink(destination: LoginView()) {
                        Text("I already have an account")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
    }
}

// Helper for Hex colors if you don't have one in Extensions
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(SessionManager())
    }
}
