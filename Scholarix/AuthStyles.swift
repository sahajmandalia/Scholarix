import SwiftUI

// MARK: - 1. Custom Text Field (Glassmorphism Style)
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20) // Fixed width for alignment
            
            TextField("", text: $text)
                // Uses the custom placeholder extension below
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(.white.opacity(0.7))
                }
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2)) // The "Glass" effect
        .cornerRadius(10)
    }
}

// MARK: - 2. Custom Secure Field (For Passwords)
struct CustomSecureField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "lock")
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            SecureField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(.white.opacity(0.7))
                }
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
    }
}

// MARK: - 3. Extension for Custom Placeholder Color
// SwiftUI default placeholders are grey; this allows us to make them white/transparent
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
