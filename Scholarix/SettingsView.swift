import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    // Local state for the toggle
    @State private var notificationsEnabled = false
    @State private var showingSignOutAlert = false
    
    private var userEmail: String {
        Auth.auth().currentUser?.email ?? "Student"
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var body: some View {
        List {
            // --- SECTION 1: PROFILE ---
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 60, height: 60)
                        
                        Text(String(userEmail.prefix(1)).uppercased())
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Signed in as")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(userEmail)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // --- SECTION 2: APPEARANCE ---
            Section(header: Text("Appearance")) {
                // iOS-Style Theme Picker
                Picker("Theme", selection: $themeManager.selectedTheme) {
                    ForEach(ThemePreference.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)
                .padding(.vertical, 4)
            }
            
            // --- SECTION 3: PREFERENCES ---
            Section(header: Text("General")) {
                // Notifications with a colorful icon
                Toggle(isOn: $notificationsEnabled) {
                    Label {
                        Text("Notifications")
                    } icon: {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.white)
                            .background(Color.red) // iOS Red for notifications
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .onChange(of: notificationsEnabled) { newValue in
                    if newValue {
                        NotificationManager.shared.requestPermission()
                    } else if let url = URL(string: UIApplication.openSettingsURLString) {
                        // Direct user to settings to turn off
                        UIApplication.shared.open(url)
                    }
                }
            }
            
            // --- SECTION 4: SUPPORT ---
            Section(header: Text("Legal & Support")) {
                
                // --- NEW WEBSITE LINK ---
                Link(destination: URL(string: "https://sites.google.com/view/scholarixapp/home")!) {
                    HStack {
                        Label {
                            Text("Website")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "globe")
                                .foregroundColor(.white)
                                .background(Color.green) // Green for website
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Privacy Policy Link
                Link(destination: URL(string: "https://sites.google.com/view/scholarixapp/legal")!) {
                    HStack {
                        Label {
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // App Version
                HStack {
                    Label {
                        Text("Version")
                    } icon: {
                        Image(systemName: "info")
                            .foregroundColor(.white)
                            .background(Color.gray)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Spacer()
                    Text(appVersion)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            
            // --- SECTION 5: DANGER ZONE ---
            Section {
                Button(role: .destructive, action: { showingSignOutAlert = true }) {
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .fontWeight(.bold)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                try? Auth.auth().signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .onAppear {
            notificationsEnabled = NotificationManager.shared.isAuthorized
        }
    }
}
