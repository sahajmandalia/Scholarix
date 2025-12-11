import SwiftUI
import Combine
import UIKit

enum ThemePreference: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

final class ThemeManager: ObservableObject {
    @AppStorage("themePreference") private var storedPreference: ThemePreference = .system {
        didSet {
            if storedPreference != selected {
                selected = storedPreference
            }
        }
    }
    
    @Published var selected: ThemePreference = .system {
        didSet {
            if selected != storedPreference {
                storedPreference = selected
            }
            applyAppearance()
        }
    }
    
    var colorScheme: ColorScheme? {
        switch selected {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    // Apply UIKit bar appearances to match the selected theme
    func applyAppearance() {
        let isDark: Bool
        switch selected {
        case .system:
            // Follow system; don't force an override style, but still reset appearances
            isDark = UITraitCollection.current.userInterfaceStyle == .dark
        case .light:
            isDark = false
        case .dark:
            isDark = true
        }

        // Navigation Bar Appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = isDark ? UIColor.black : UIColor.white
        navAppearance.titleTextAttributes = [.foregroundColor: isDark ? UIColor.white : UIColor.black]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: isDark ? UIColor.white : UIColor.black]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = isDark ? .white : .black

        // Tab Bar Appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = isDark ? UIColor.black : UIColor.white
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = isDark ? .white : .black
        UITabBar.appearance().unselectedItemTintColor = isDark ? UIColor.lightGray : UIColor.darkGray

        // Optionally force the key window style when not following system
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                switch selected {
                case .system:
                    window.overrideUserInterfaceStyle = .unspecified
                case .light:
                    window.overrideUserInterfaceStyle = .light
                case .dark:
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
    
    init() {
        // Initialize without touching @AppStorage via self before all properties are set
        self.selected = .system
        // Now that self is initialized, read from AppStorage
        self.selected = storedPreference
        applyAppearance()
    }
}

