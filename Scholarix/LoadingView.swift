import SwiftUI

struct LoadingView: View {
    @State private var showContent = false
    @State private var quoteIndex = 0
    @State private var animateGradient = false
    @State private var rotateIcon = false
    
    // Motivational quotes for students
    private let quotes = [
        "The expert in anything was once a beginner 🌱",
        "Success is the sum of small efforts, repeated daily 💪",
        "Don't let yesterday take up too much of today ⏰",
        "You are capable of more than you know 🚀",
        "Focus on the step in front of you 👣",
        "Study hard, for the well is deep 📚",
        "Education is your most powerful weapon 🎓",
        "Believe you can and you're halfway there ✨",
        "Your future is created by what you do today 🌟",
        "The best way to predict your future is to create it 🎯"
    ]
    
    var body: some View {
        ZStack {
            // Animated Gradient Background
            Theme.brandGradient
                .ignoresSafeArea()
                .overlay(
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 400, height: 400)
                            .blur(radius: 60)
                            .offset(x: animateGradient ? -100 : 100, y: animateGradient ? -150 : 150)
                        
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 300, height: 300)
                            .blur(radius: 40)
                            .offset(x: animateGradient ? 120 : -120, y: animateGradient ? 180 : -180)
                    }
                )
            
            VStack(spacing: 35) {
                Spacer()
                
                // Animated Logo Container with Pulse Effect
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                            .frame(width: 160 + CGFloat(index * 20), height: 160 + CGFloat(index * 20))
                            .scaleEffect(showContent ? 1.0 : 0.5)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.easeOut(duration: 1.0).delay(Double(index) * 0.2).repeatForever(autoreverses: false), value: showContent)
                    }
                    
                    // Main logo circle
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 150, height: 150)
                        .blur(radius: 8)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 150, height: 150)
                    
                    Image("AppLogo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.6), radius: 15, x: 0, y: 0)
                        .rotationEffect(.degrees(rotateIcon ? 360 : 0))
                }
                .scaleEffect(showContent ? 1.0 : 0.7)
                .opacity(showContent ? 1.0 : 0.0)
                
                // App Name with Subtitle
                VStack(spacing: 8) {
                    Text("Scholarix")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(1.5)
                    
                    Text("Your Student OS")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1.2)
                        .textCase(.uppercase)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // Motivational Quote Area with Card Style
                VStack(spacing: 20) {
                    // Loading indicator
                    HStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.3)
                        
                        Text("Loading your workspace...")
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                    
                    // Quote
                    Text(quotes[quoteIndex])
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .italic()
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 45)
                        .padding(.vertical, 6)
                        .transition(.opacity)
                        .id(quoteIndex)
                }
                .padding(.bottom, 70)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            quoteIndex = Int.random(in: 0..<quotes.count)
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showContent = true
            }
            
            withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
            
            withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
                rotateIcon = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
