import SwiftUI
import UIKit
import Combine

// 1. Define the options clearly
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

// 2. The Manager
class ThemeManager: ObservableObject {
    // Persist the user's choice
    @AppStorage("selected_theme") var selectedTheme: ThemePreference = .system {
        didSet {
            updateAppAppearance()
        }
    }
    
    init() {
        updateAppAppearance()
    }
    
    // Helper for SwiftUI .preferredColorScheme modifier
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    // Helper for UIKit (Alerts, Sheets, etc.)
    func updateAppAppearance() {
        let style: UIUserInterfaceStyle
        
        switch selectedTheme {
        case .system: style = .unspecified
        case .light: style = .light
        case .dark: style = .dark
        }
        
        // Force the window to adopt the style immediately
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            scene.windows.forEach { window in
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}
