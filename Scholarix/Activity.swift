import Foundation
import FirebaseFirestore

struct Activity: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    
    var title: String          // e.g., "Debate Club"
    var position: String       // e.g., "President" or "Member"
    var type: String           // e.g., "Club", "Sport", "Service", "Award"
    var hours: Double?         // e.g., 50.0
    var startDate: Date
    var endDate: Date?         // Nil implies "Present" / Ongoing
    var description: String?   // Key achievements
    
    // Helper: Check if activity is currently active
    var isOngoing: Bool {
        return endDate == nil
    }
}
