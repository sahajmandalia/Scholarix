import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // --- ADD THIS NEW FUNCTION ---
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }
}
#endif

// MARK: - Wellness Mood Helper
extension String {
    /// Returns an emoji representation for wellness mood strings
    func wellnessMoodEmoji() -> String {
        switch self {
        case "Energized": return "⚡️"
        case "Content": return "😊"
        case "Tired": return "😴"
        case "Stressed": return "😰"
        case "Anxious": return "😟"
        default: return "😊"
        }
    }
}
