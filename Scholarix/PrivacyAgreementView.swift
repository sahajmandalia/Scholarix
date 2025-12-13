import SwiftUI

struct PrivacyAgreementView: View {
    @AppStorage("hasAgreedToPrivacy") var hasAgreedToPrivacy: Bool = false
    @State private var isChecked = false
    @State private var showingAlert = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Privacy & Terms")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Before you start using Scholarix, please review and agree to our Privacy Policy.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Policy Link
                Link(destination: URL(string: "https://www.sites.google.com/scholarixapp/legal")!) { // Replace with actual URL
                    HStack {
                        Text("Read Privacy Policy")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.up.right.square")
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
                
                // Checkbox
                Button(action: { isChecked.toggle() }) {
                    HStack {
                        Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            .font(.title2)
                            .foregroundColor(isChecked ? .blue : .gray)
                        Text("I agree to the Privacy Policy")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 10)
                
                // Continue Button
                Button(action: {
                    if isChecked {
                        hasAgreedToPrivacy = true
                    } else {
                        showingAlert = true
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isChecked ? Color.blue : Color.gray)
                        .cornerRadius(15)
                }
                .disabled(!isChecked)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .alert("Agreement Required", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You must agree to the Privacy Policy to continue.")
        }
    }
}
