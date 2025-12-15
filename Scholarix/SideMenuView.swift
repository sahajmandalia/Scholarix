import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @EnvironmentObject var menuManager: MenuManager
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? "Student"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header with User Info
                VStack(alignment: .leading, spacing: 16) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Theme.brandGradient)
                            .frame(width: 70, height: 70)
                            .shadow(color: Theme.brandPrimary.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Text(String(userEmail.prefix(1)).uppercased())
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    // User Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hey there! 👋")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(userEmail)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                }
                .padding(.top, 65)
                .padding(.bottom, 35)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Theme.brandGradient)
                
                // Menu Items
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 4) {
                        MenuRow(
                            icon: "person.crop.circle.fill",
                            title: "Profile",
                            color: Theme.brandPrimary
                        ) {
                            menuManager.close()
                        }
                        
                        MenuRow(
                            icon: "gearshape.fill",
                            title: "Settings",
                            color: Theme.textSecondary
                        ) {
                            menuManager.openSettings()
                        }
                        
                        MenuRow(
                            icon: "doc.richtext.fill",
                            title: "Resume",
                            color: Theme.brandAccent
                        ) {
                            menuManager.close()
                        }
                        
                        // Help Link
                        Link(destination: URL(string: "https://sites.google.com/view/scholarixapp/about-support")!) {
                            HStack(spacing: 14) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Theme.info)
                                    .frame(width: 28)
                                
                                Text("Help & Support")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundColor(Theme.textTertiary)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        
                        Divider()
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        
                        // Log Out Button
                        Button(action: {
                            try? Auth.auth().signOut()
                            menuManager.close()
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: "arrow.right.square.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Theme.danger)
                                    .frame(width: 28)
                                
                                Text("Log Out")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Theme.danger)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Theme.danger.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // App Version Footer
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 10, weight: .semibold))
                    Text("Scholarix v1.0")
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                }
                .foregroundColor(Theme.textTertiary)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(width: 290)
            .background(Theme.backgroundPrimary)
            .shadow(color: Theme.shadowMedium, radius: 20, x: 5, y: 0)
            .edgesIgnoringSafeArea(.vertical)
            
            Spacer()
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.textTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Theme.cardBackground.opacity(0.5))
            .cornerRadius(12)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
