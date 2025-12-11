import SwiftUI

struct LoadingView: View {
    @State private var showContent = false
    @State private var quoteIndex = 0
    @State private var animateGradient = false
    
    // A collection of motivational quotes for students
    private let quotes = [
        "The expert in anything was once a beginner.",
        "Success is the sum of small efforts, repeated day in and day out.",
        "Don't let yesterday take up too much of today.",
        "You are capable of more than you know.",
        "Focus on the step in front of you, not the whole staircase.",
        "Study hard, for the well is deep, and our brains are shallow.",
        "Education is the most powerful weapon which you can use to change the world.",
        "Believe you can and you're halfway there.",
        "Your future is created by what you do today, not tomorrow.",
        "The best way to predict your future is to create it."
    ]
    
    var body: some View {
        ZStack {
            // --- 1. Animated Gradient Background ---
            LinearGradient(
                colors: [
                    Color.blue,
                    Color.purple,
                    Color(red: 0.2, green: 0.1, blue: 0.6) // Deep Indigo
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            // --- 2. Main Content ---
            VStack(spacing: 30) {
                Spacer()
                
                // Animated Logo Container
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 140, height: 140)
                        .blur(radius: 5)
                    
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 140, height: 140)
                    
                    Image("AppLogo") // Uses your existing asset
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                }
                .scaleEffect(showContent ? 1.0 : 0.8)
                .opacity(showContent ? 1.0 : 0.0)
                
                // App Name
                Text("Scholarix")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1.5)
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                // --- 3. Motivational Quote Area ---
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                    
                    Text("\"\(quotes[quoteIndex])\"")
                        .font(.system(.body, design: .serif))
                        .italic()
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity)
                        .id(quoteIndex) // Forces redraw for animation when index changes
                }
                .padding(.bottom, 60)
                .opacity(showContent ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // Pick a random quote each time the view appears
            quoteIndex = Int.random(in: 0..<quotes.count)
            
            // Trigger entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showContent = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
