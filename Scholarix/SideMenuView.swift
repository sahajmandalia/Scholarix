import SwiftUI
import FirebaseAuth

struct SideMenuView: View {
    @EnvironmentObject var menuManager: MenuManager
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? "Student"
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                // --- Header ---
                VStack(alignment: .leading, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 60, height: 60)
                        Text(String(userEmail.prefix(1)).uppercased())
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello,")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text(userEmail)
                            .font(.headline)
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 30)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                
                // --- Menu Items ---
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        MenuRow(icon: "person.fill", title: "Profile") { menuManager.close() }
                        MenuRow(icon: "gearshape.fill", title: "Settings") { menuManager.openSettings() }
                        MenuRow(icon: "doc.text.fill", title: "Resume") { menuManager.close() } // Navigates to Extracurriculars tab via main view logic if needed, or just closes
                        MenuRow(icon: "questionmark.circle.fill", title: "Help") { menuManager.close() }
                        
                        Divider().padding(.vertical)
                        
                        Button(action: {
                            try? Auth.auth().signOut()
                            menuManager.close()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.left.square.fill")
                                    .foregroundColor(.red)
                                Text("Log Out")
                                    .foregroundColor(.red)
                            }
                            .padding()
                        }
                    }
                    .padding(.top)
                }
                
                Spacer()
                
                Text("Scholarix v1.0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .frame(width: 270)
            .background(Color(.systemBackground))
            .edgesIgnoringSafeArea(.vertical)
            
            Spacer()
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .frame(width: 24)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}
