import SwiftUI

struct Theme {
    // MARK: - Brand Colors (Vibrant & Student-Friendly)
    static let brandPrimary = Color("BrandPrimary", fallback: Color(red: 0.0, green: 0.48, blue: 1.0)) // Bright Blue
    static let brandSecondary = Color("BrandSecondary", fallback: Color(red: 0.69, green: 0.32, blue: 0.87)) // Vibrant Purple
    static let brandAccent = Color("BrandAccent", fallback: Color(red: 0.0, green: 0.78, blue: 0.75)) // Teal Accent
    
    static let brandGradient = LinearGradient(
        gradient: Gradient(colors: [brandPrimary, brandSecondary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [brandAccent, brandPrimary]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Semantic Colors (Status & Feedback)
    static let success = Color("Success", fallback: Color(red: 0.2, green: 0.78, blue: 0.35)) // Green
    static let warning = Color("Warning", fallback: Color(red: 1.0, green: 0.58, blue: 0.0)) // Orange
    static let danger = Color("Danger", fallback: Color(red: 1.0, green: 0.23, blue: 0.19)) // Red
    static let info = Color("Info", fallback: Color(red: 0.35, green: 0.78, blue: 0.98)) // Light Blue
    
    // MARK: - Background Colors (Adaptive)
    static let backgroundPrimary = Color("BackgroundPrimary", fallback: Color(.systemBackground))
    static let backgroundSecondary = Color("BackgroundSecondary", fallback: Color(.secondarySystemBackground))
    static let backgroundTertiary = Color("BackgroundTertiary", fallback: Color(.tertiarySystemBackground))
    static let backgroundGrouped = Color("BackgroundGrouped", fallback: Color(.systemGroupedBackground))
    
    // MARK: - Surface Colors (Cards & Containers)
    static let cardBackground = Color("CardBackground", fallback: Color(.secondarySystemGroupedBackground))
    static let cardBackgroundElevated = Color("CardBackgroundElevated", fallback: Color(.tertiarySystemGroupedBackground))
    static let inputBackground = Color("InputBackground", fallback: Color(.systemGray6))
    
    // MARK: - Text Colors (Adaptive)
    static let textPrimary = Color("TextPrimary", fallback: Color(.label))
    static let textSecondary = Color("TextSecondary", fallback: Color(.secondaryLabel))
    static let textTertiary = Color("TextTertiary", fallback: Color(.tertiaryLabel))
    static let textPlaceholder = Color("TextPlaceholder", fallback: Color(.placeholderText))
    
    // MARK: - Border & Separator Colors
    static let border = Color("Border", fallback: Color(.separator))
    static let borderSubtle = Color("BorderSubtle", fallback: Color(.systemGray5))
    static let divider = Color("Divider", fallback: Color(.separator))
    
    // MARK: - Interactive Colors
    static let buttonPrimary = brandPrimary
    static let buttonSecondary = Color("ButtonSecondary", fallback: Color(.systemGray4))
    static let buttonDisabled = Color("ButtonDisabled", fallback: Color(.systemGray3))
    
    // MARK: - Academic Grade Colors (Student-Friendly)
    static let gradeA = Color("GradeA", fallback: Color(red: 0.2, green: 0.78, blue: 0.35)) // Green
    static let gradeB = Color("GradeB", fallback: Color(red: 0.0, green: 0.48, blue: 1.0)) // Blue
    static let gradeC = Color("GradeC", fallback: Color(red: 1.0, green: 0.58, blue: 0.0)) // Orange
    static let gradeD = Color("GradeD", fallback: Color(red: 1.0, green: 0.23, blue: 0.19)) // Red
    
    // MARK: - Activity Type Colors (Vibrant & Distinct)
    static let activityTest = Color("ActivityTest", fallback: Color(red: 1.0, green: 0.23, blue: 0.19))
    static let activityProject = Color("ActivityProject", fallback: Color(red: 0.69, green: 0.32, blue: 0.87))
    static let activityEssay = Color("ActivityEssay", fallback: Color(red: 1.0, green: 0.58, blue: 0.0))
    static let activityApplication = Color("ActivityApplication", fallback: Color(red: 1.0, green: 0.38, blue: 0.78))
    static let activityEvent = Color("ActivityEvent", fallback: Color(red: 1.0, green: 0.8, blue: 0.0))
    static let activityClub = Color("ActivityClub", fallback: Color(red: 0.0, green: 0.78, blue: 0.75))
    static let activitySport = Color("ActivitySport", fallback: Color(red: 0.2, green: 0.78, blue: 0.35))
    static let activityDefault = brandPrimary
    
    // MARK: - Shadow & Overlay
    static let shadowLight = Color.black.opacity(0.05)
    static let shadowMedium = Color.black.opacity(0.1)
    static let shadowHeavy = Color.black.opacity(0.2)
    static let overlay = Color.black.opacity(0.4)
    
    // MARK: - Helper Methods
    static func gradeColor(for percentage: Double) -> Color {
        switch percentage {
        case 90...110: return gradeA
        case 80..<90: return gradeB
        case 70..<80: return gradeC
        default: return gradeD
        }
    }
    
    static func activityColor(for type: String) -> Color {
        switch type.lowercased() {
        case "test": return activityTest
        case "project": return activityProject
        case "essay": return activityEssay
        case "application": return activityApplication
        case "event": return activityEvent
        case "club": return activityClub
        case "sport": return activitySport
        default: return activityDefault
        }
    }
}

// MARK: - Color Extension for Asset Catalog Support
extension Color {
    init(_ name: String, fallback: Color) {
        if let _ = UIColor(named: name) {
            self.init(name)
        } else {
            self = fallback
        }
    }
}
