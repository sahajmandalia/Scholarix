import Foundation

struct Constants {
    static let appId = "scholarix-app"
    
    struct Firestore {
        static let root = "artifacts"
        static let users = "users"
        static let courses = "courses"
        static let deadlines = "deadlines"
        static let activities = "activities" // Added this line
    }
    
    struct Keys {
        static let notificationsEnabled = "notificationsEnabled"
    }
}
