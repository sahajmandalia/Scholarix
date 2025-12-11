import Foundation
import Combine
import FirebaseAuth
import FirebaseCore // Added for robustness in recognizing Firebase types

class SessionManager: ObservableObject {
    // Note: User type now implicitly comes from FirebaseAuth.
    @Published var user: User?
    @Published var isLoading = true
    
    private var listenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Start listening to auth changes
        self.listenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isLoading = false
            }
        }
    }
    
    deinit {
        // Clean up the listener
        if let handle = listenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
