import SwiftUI
import Combine

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
    
    @Published var selected: ThemePreference {
        didSet {
            if selected != storedPreference {
                storedPreference = selected
            }
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
    
    init() {
        self.selected = storedPreference
    }
}
