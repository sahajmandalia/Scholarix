import Foundation
import FirebaseFirestore

struct WellnessLog: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var sleepHours: Double
    var waterIntake: Int // in ounces
    var exerciseMinutes: Int
    var mood: String
    
    // Custom Goals (per user)
    var sleepGoal: Double?
    var waterGoal: Int?
    var exerciseGoal: Int?
    
    // Default Goals (used when custom goals not set)
    static let defaultSleepGoal: Double = 8.0
    static let defaultWaterGoal: Int = 64
    static let defaultExerciseGoal: Int = 60
    
    // Helper methods to get effective goals
    func effectiveSleepGoal() -> Double {
        return sleepGoal ?? WellnessLog.defaultSleepGoal
    }
    
    func effectiveWaterGoal() -> Int {
        return waterGoal ?? WellnessLog.defaultWaterGoal
    }
    
    func effectiveExerciseGoal() -> Int {
        return exerciseGoal ?? WellnessLog.defaultExerciseGoal
    }
}
