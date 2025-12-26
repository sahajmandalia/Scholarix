import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseFirestore
import Combine

@MainActor
class AcademicViewModel: ObservableObject {
    
    @Published var courses = [Course]()
    @Published var unweightedGPA: String = "0.00"
    @Published var weightedGPA: String = "0.00"
    @Published var deadlines = [Deadline]()
    @Published var searchText = ""
    @Published var errorMessage: String?
    
    var filteredCourses: [Course] {
        if searchText.isEmpty { return courses }
        return courses.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.courseLevel.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredDeadlines: [Deadline] {
        if searchText.isEmpty { return deadlines }
        return deadlines.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.type.localizedCaseInsensitiveContains(searchText) }
    }
    
    private var coursesListener: ListenerRegistration?
    private var deadlinesListener: ListenerRegistration?
    
    // RESTORED: Standard Firestore path for users
    private func userDoc(_ userId: String) -> DocumentReference {
        return Firestore.firestore()
            .collection(Constants.Firestore.root).document(Constants.appId)
            .collection(Constants.Firestore.users).document(userId)
    }
    
    func fetchCourses() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.coursesListener = userDoc(userId).collection("courses").addSnapshotListener { [weak self] qs, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = "Error fetching courses: \(error.localizedDescription)"
                return
            }
            guard let docs = qs?.documents else { return }
            self.courses = docs.compactMap { try? $0.data(as: Course.self) }
            self.calculateGPA()
        }
    }
    
    func fetchDeadlines() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        self.deadlinesListener = userDoc(userId).collection("deadlines").order(by: "dueDate").addSnapshotListener { [weak self] qs, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = "Error fetching deadlines: \(error.localizedDescription)"
                return
            }
            guard let docs = qs?.documents else { return }
            self.deadlines = docs.compactMap { try? $0.data(as: Deadline.self) }
        }
    }
    
    private func calculateGPA() {
        let (u, w) = GPAService.calculate(courses: courses)
        unweightedGPA = u
        weightedGPA = w
    }
    
    func detachListeners() {
        coursesListener?.remove()
        deadlinesListener?.remove()
    }
    
    // MARK: - CRUD Operations
    
    func addDeadline(deadline: Deadline) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let docRef = try await userDoc(userId).collection("deadlines").addDocument(from: deadline)
        
        var deadlineWithId = deadline
        deadlineWithId.id = docRef.documentID
        NotificationManager.shared.scheduleNotification(for: deadlineWithId)
    }
    
    func deleteCourse(course: Course) {
        guard let uid = Auth.auth().currentUser?.uid, let id = course.id else { return }
        userDoc(uid).collection("courses").document(id).delete()
    }
    
    func deleteDeadline(deadline: Deadline) {
        guard let uid = Auth.auth().currentUser?.uid, let id = deadline.id else { return }
        NotificationManager.shared.cancelNotification(for: deadline)
        userDoc(uid).collection("deadlines").document(id).delete()
    }
    
    func updateCourse(course: Course) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let id = course.id else { throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]) }
        try await userDoc(uid).collection("courses").document(id).setData(from: course)
    }
    
    func updateDeadline(deadline: Deadline) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let id = deadline.id else { throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]) }
        try await userDoc(uid).collection("deadlines").document(id).setData(from: deadline)
        NotificationManager.shared.scheduleNotification(for: deadline)
    }
    
    func toggleCompletion(deadline: Deadline) {
        guard let uid = Auth.auth().currentUser?.uid, let id = deadline.id else { return }
        var updated = deadline
        updated.isCompleted.toggle()
        
        Task {
            try? await userDoc(uid).collection("deadlines").document(id).setData(from: updated)
            if updated.isCompleted {
                NotificationManager.shared.cancelNotification(for: updated)
            } else {
                NotificationManager.shared.scheduleNotification(for: updated)
            }
        }
    }
}

