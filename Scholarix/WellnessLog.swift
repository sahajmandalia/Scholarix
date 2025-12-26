import Foundation
import FirebaseFirestore

struct WellnessLog: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var sleepHours: Double
    var waterIntake: Int // in ounces
    var exerciseMinutes: Int
    var mood: String
    
    // Default Goals
    static let sleepGoal: Double = 8.0
    static let waterGoal: Int = 64
    static let exerciseGoal: Int = 60
}
