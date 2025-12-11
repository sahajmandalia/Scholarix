import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var menuManager = MenuManager()
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        ZStack {
            if sessionManager.isLoading {
                ProgressView().scaleEffect(1.5)
            } else if let user = sessionManager.user {
                if user.isEmailVerified {
                    mainAppInterface
                    
                    if menuManager.showSettings {
                        NavigationView {
                            // FIX: Removed argument
                            SettingsView()
                                .navigationBarTitle("Settings", displayMode: .inline)
                                .navigationBarItems(leading: Button(action: {
                                    withAnimation {
                                        menuManager.showSettings = false
                                    }
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
                } else {
                    VerificationSentView(email: user.email ?? "your email")
                }
            } else {
                NavigationView {
                    WelcomeView()
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
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
