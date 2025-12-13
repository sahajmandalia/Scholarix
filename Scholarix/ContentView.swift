import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var menuManager = MenuManager()
    @StateObject private var themeManager = ThemeManager()
    
    @AppStorage("hasAgreedToPrivacy") private var hasAgreedToPrivacy = false
    
    var body: some View {
        ZStack {
            if sessionManager.isLoading {
                // 1. Loading
                ProgressView().scaleEffect(1.5)
                
            } else if let user = sessionManager.user {
                // 2. LOGGED IN USER
                if user.isEmailVerified {
                    if hasAgreedToPrivacy {
                        // A. Verified & Agreed -> Main App
                        mainAppInterface
                    } else {
                        // B. Verified but NOT Agreed -> Privacy Screen
                        PrivacyAgreementView()
                    }
                } else {
                    // C. Not Verified -> Waiting Screen
                    VerificationSentView(email: user.email ?? "your email")
                }
                
            } else {
                // 4. LOGGED OUT -> Welcome Screen
                NavigationView {
                    WelcomeView()
                }
            }
            
            // Settings Overlay (Available in Main App)
            if menuManager.showSettings {
                NavigationView {
                    SettingsView()
                        .navigationBarTitle("Settings", displayMode: .inline)
                        .navigationBarItems(leading: Button(action: {
                            withAnimation { menuManager.showSettings = false }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        })
                }
                .transition(.move(edge: .trailing))
                .zIndex(3)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .environmentObject(menuManager)
        .animation(.easeInOut(duration: 0.3), value: menuManager.isOpen)
        .animation(.easeInOut(duration: 0.3), value: menuManager.showSettings)
    }
    
    var mainAppInterface: some View {
        ZStack(alignment: .leading) {
            MainTabView()
                .offset(x: menuManager.isOpen ? 270 : 0)
                .disabled(menuManager.isOpen)
            
            if menuManager.isOpen {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { menuManager.close() }
                    .zIndex(1)
                
                SideMenuView()
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }
        }
    }
}
