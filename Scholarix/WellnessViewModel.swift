import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class WellnessViewModel: ObservableObject {
    @Published var todayLog: WellnessLog?
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Generates a consistent ID for today (e.g., "2025-12-25")
    private var todayDocId: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
    
    private func userWellnessRef(_ uid: String) -> DocumentReference {
        return db.collection("users").document(uid).collection("wellness").document(todayDocId)
    }
    
    func fetchTodayLog() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Remove existing listener to prevent memory leaks
        listener?.remove()
        
        listener = userWellnessRef(uid).addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                self.todayLog = try? snapshot.data(as: WellnessLog.self)
            } else {
                self.todayLog = nil // Shows the "Start Your Day" setup UI
            }
        }
    }
    
    func createDay(sleep: Double, mood: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let log = WellnessLog(
            date: Date(),
            sleepHours: sleep,
            waterIntake: 0,
            exerciseMinutes: 0,
            mood: mood
        )
        
        try? userWellnessRef(uid).setData(from: log)
    }
    
    func updateMetric(key: String, value: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userWellnessRef(uid).updateData([key: value])
    }
    
    func detachListener() {
        listener?.remove()
    }
}
