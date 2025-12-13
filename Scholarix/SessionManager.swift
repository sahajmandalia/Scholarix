import Foundation
import Combine
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isLoading = true
    @Published var isGuest = false // New flag for Guest Mode
    
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoading = false
                // If a user logs in, they are no longer a guest
                if user != nil {
                    self?.isGuest = false
                }
            }
        }
    }
    
    deinit {
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
