import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class WellnessViewModel: ObservableObject {
    @Published var todayLog: WellnessLog?
    @Published var weekLogs: [WellnessLog] = []
    @Published var allLogs: [WellnessLog] = []
    @Published var currentStreak: Int = 0
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var weekListener: ListenerRegistration?
    private var allLogsListener: ListenerRegistration?
    private var lastStreakCalculation: Date?
    private var streakCalculationCache: Int = 0
    
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
    
    private func userWellnessCollection(_ uid: String) -> CollectionReference {
        return db.collection("users").document(uid).collection("wellness")
    }
    
    /// Coordinates all data fetching to avoid excessive concurrent requests
    func fetchAllData() {
        fetchTodayLog()
        
        // Stagger secondary fetches slightly to avoid simultaneous requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchWeekLogs()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.fetchAllLogs()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.calculateStreak()
        }
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
    
    func fetchWeekLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Calculate date 7 days ago
        let calendar = Calendar.current
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return }
        
        weekListener?.remove()
        
        weekListener = userWellnessCollection(uid)
            .whereField("date", isGreaterThanOrEqualTo: weekAgo)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.weekLogs = snapshot?.documents.compactMap {
                    try? $0.data(as: WellnessLog.self)
                } ?? []
            }
    }
    
    func fetchAllLogs() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        allLogsListener?.remove()
        
        allLogsListener = userWellnessCollection(uid)
            .order(by: "date", descending: true)
            .limit(to: 30) // Limit to last 30 logs for performance
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.allLogs = snapshot?.documents.compactMap {
                    try? $0.data(as: WellnessLog.self)
                } ?? []
            }
    }
    
    func calculateStreak() {
        // Check if we already calculated today
        if let lastCalc = lastStreakCalculation,
           Calendar.current.isDateInToday(lastCalc) {
            currentStreak = streakCalculationCache
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        userWellnessCollection(uid)
            .order(by: "date", descending: true)
            .limit(to: 100)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else {
                    self.currentStreak = 0
                    return
                }
                
                let logs = documents.compactMap { try? $0.data(as: WellnessLog.self) }
                    .sorted { $0.date > $1.date }
                
                var streak = 0
                var checkDate = today
                
                for log in logs {
                    let logDate = calendar.startOfDay(for: log.date)
                    
                    if logDate == checkDate {
                        streak += 1
                        checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
                    } else if logDate < checkDate {
                        break
                    }
                }
                
                self.currentStreak = streak
                self.streakCalculationCache = streak
                self.lastStreakCalculation = Date()
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
        
        do {
            try userWellnessRef(uid).setData(from: log) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // Successfully saved to Firestore, listener will update UI
                    print("Wellness log created successfully")
                }
            }
            // Optimistically update local state for immediate UI feedback
            self.todayLog = log
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func updateMetric(key: String, value: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userWellnessRef(uid).updateData([key: value])
    }
    
    func detachListener() {
        listener?.remove()
        weekListener?.remove()
        allLogsListener?.remove()
    }
}
