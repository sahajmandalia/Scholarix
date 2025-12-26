import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class ExtracurricularsViewModel: ObservableObject {
    @Published var activities = [Activity]()
    @Published var searchText = ""
    @Published var errorMessage: String?
    
    var filteredActivities: [Activity] {
        if searchText.isEmpty { return activities }
        return activities.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.type.localizedCaseInsensitiveContains(searchText) ||
            $0.position.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var totalHours: Double {
        activities.reduce(0) { $0 + ($1.hours ?? 0) }
    }
    
    var activeCount: Int {
        activities.filter { $0.isOngoing }.count
    }
    
    private var listener: ListenerRegistration?
    
    // RESTORED: Standard Firestore path for activities
    private func userActivitiesRef(_ uid: String) -> CollectionReference {
        return Firestore.firestore()
            .collection(Constants.Firestore.root).document(Constants.appId)
            .collection(Constants.Firestore.users).document(uid)
            .collection(Constants.Firestore.activities)
    }
    
    func fetchActivities() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listener = userActivitiesRef(uid)
            .order(by: "startDate", descending: true)
            .addSnapshotListener { [weak self] qs, error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                    return
                }
                self.activities = qs?.documents.compactMap { try? $0.data(as: Activity.self) } ?? []
            }
    }
    
    func detachListener() {
        listener?.remove()
    }
    
    // MARK: - CRUD
    
    func addActivity(_ activity: Activity) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try userActivitiesRef(uid).addDocument(from: activity)
    }
    
    func updateActivity(_ activity: Activity) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let id = activity.id else { return }
        try await userActivitiesRef(uid).document(id).setData(from: activity)
    }
    
    func deleteActivity(_ activity: Activity) {
        guard let uid = Auth.auth().currentUser?.uid, let id = activity.id else { return }
        userActivitiesRef(uid).document(id).delete()
    }
}
