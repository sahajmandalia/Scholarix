import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var notificationsEnabled = false
    @State private var showingSignOutAlert = false
    
    private var userEmail: String {
        Auth.auth().currentUser?.email ?? "Student"
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.brandGradient)
                                .frame(width: 70, height: 70)
                                .shadow(color: Theme.brandPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Text(String(userEmail.prefix(1)).uppercased())
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Account")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.textSecondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            
                            Text(userEmail)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.textPrimary)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                        }
                    }
                    .padding(.vertical, 12)
                    .listRowBackground(Theme.cardBackground)
                }
                
                // Appearance Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.brandPrimary)
                            Text("Theme")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundColor(Theme.textPrimary)
                        }
                        
                        Picker("Theme", selection: $themeManager.selectedTheme) {
                            ForEach(ThemePreference.allCases) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .listRowSeparator(.hidden)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Theme.cardBackground)
                } header: {
                    Text("Appearance")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Preferences Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.danger)
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notifications")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.textPrimary)
                                Text("Get reminders for deadlines")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        }
                    }
                    .tint(Theme.brandPrimary)
                    .listRowBackground(Theme.cardBackground)
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.requestPermission()
                        } else if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("Preferences")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Support Section
                Section {
                    SettingsLink(
                        icon: "globe",
                        iconColor: Theme.success,
                        title: "Website",
                        subtitle: "Visit scholarixapp.com",
                        url: "https://sites.google.com/view/scholarixapp/home"
                    )
                    
                    SettingsLink(
                        icon: "hand.raised.fill",
                        iconColor: Theme.brandPrimary,
                        title: "Privacy Policy",
                        subtitle: "How we protect your data",
                        url: "https://sites.google.com/view/scholarixapp/legal"
                    )
                    
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Theme.textSecondary.opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(Theme.textPrimary)
                            Text("App version number")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text(appVersion)
                            .font(.system(.callout, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .listRowBackground(Theme.cardBackground)
                } header: {
                    Text("About & Legal")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textSecondary)
                }
                
                // Sign Out Section
                Section {
                    Button(role: .destructive, action: { showingSignOutAlert = true }) {
                        HStack {
                            Spacer()
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Sign Out")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .foregroundColor(Theme.danger)
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Theme.danger.opacity(0.1))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out?", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                try? Auth.auth().signOut()
            }
        } message: {
            Text("Are you sure you want to sign out of your account?")
        }
        .onAppear {
            notificationsEnabled = NotificationManager.shared.isAuthorized
        }
    }
}

// MARK: - Settings Link Component
struct SettingsLink: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let url: String
    
    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
        }
        .listRowBackground(Theme.cardBackground)
    }
}
