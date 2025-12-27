import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Hub 1: Academic (Grades & Calendar)
            AcademicView()
                .tabItem {
                    Label {
                        Text("Academic")
                            .font(.system(.caption, design: .rounded))
                    } icon: {
                        Image(systemName: selectedTab == 0 ? "book.fill" : "book")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                    }
                }
                .tag(0)
            
            // Hub 2: Health & Wellness - UPDATED FROM ComingSoonView TO WellnessView
            WellnessView()
                .tabItem {
                    Label {
                        Text("Wellness")
                            .font(.system(.caption, design: .rounded))
                    } icon: {
                        Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                    }
                }
                .tag(1)
            // Hub 4: Extracurriculars
            ExtracurricularsView()
                .tabItem {
                    Label {
                        Text("Activities")
                            .font(.system(.caption, design: .rounded))
                    } icon: {
                        Image(systemName: selectedTab == 3 ? "trophy.fill" : "trophy")
                            .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                    }
                }
                .tag(3)
        }
        .accentColor(Theme.brandPrimary)
        .toolbar(.visible, for: .tabBar)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

// MARK: - Coming Soon View (Remains unchanged for other placeholders)
struct ComingSoonView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        ZStack {
            Theme.backgroundGrouped.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(color)
                    .padding(32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 3)
                    )
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(.title, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(subtitle)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "hammer.fill")
                            .font(.caption)
                        Text("Coming Soon")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(color)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(color.opacity(0.1))
                    .cornerRadius(20)
                    .padding(.top, 8)
                }
                
                Spacer()
                Spacer()
            }
        }
    }
}
