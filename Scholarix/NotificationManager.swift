import UserNotifications
import SwiftUI
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var isAuthorized = false
    
    init() {
        checkPermissions()
    }
    
    func checkPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("✅ Notifications Authorized")
                } else if let error = error {
                    print("❌ Error requesting notifications: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // --- SMART SCHEDULING LOGIC ---
    func scheduleNotification(for deadline: Deadline) {
        // 1. Remove existing notifications for this ID to avoid duplicates (important for updates)
        cancelNotification(for: deadline)
        
        guard let id = deadline.id else { return }
        
        // 2. Define Content
        let content = UNMutableNotificationContent()
        content.sound = .default
        
        // 3. Determine Logic based on Type
        let isEvent = ["Event", "Club", "Sport", "Other"].contains(deadline.type)
        
        if isEvent {
            // --- EVENT LOGIC: Remind 30 mins before ---
            content.title = "Upcoming: \(deadline.title)"
            content.body = "\(deadline.type) starts in 30 minutes."
            
            // Calculate trigger date (30 mins before due date)
            if let triggerDate = Calendar.current.date(byAdding: .minute, value: -30, to: deadline.dueDate), triggerDate > Date() {
                let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                addRequest(id: "\(id)_start", content: content, trigger: trigger)
            }
            
        } else {
            // --- TASK LOGIC: Two Reminders ---
            
            // A. The "Do it now" Reminder (24 Hours Before)
            let dayBeforeContent = UNMutableNotificationContent()
            dayBeforeContent.title = "Due Tomorrow: \(deadline.title)"
            dayBeforeContent.body = "Don't forget to finish this \(deadline.type.lowercased())."
            dayBeforeContent.sound = .default
            
            if let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: deadline.dueDate), dayBefore > Date() {
                let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dayBefore)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                addRequest(id: "\(id)_24h", content: dayBeforeContent, trigger: trigger)
            }
            
            // B. The "Submit it" Reminder (Morning of Due Date - 8:00 AM)
            let morningContent = UNMutableNotificationContent()
            morningContent.title = "Due Today: \(deadline.title)"
            morningContent.body = "Make sure to turn in your \(deadline.type.lowercased())!"
            morningContent.sound = .default
            
            var morningComps = Calendar.current.dateComponents([.year, .month, .day], from: deadline.dueDate)
            morningComps.hour = 8
            morningComps.minute = 0
            
            if let morningDate = Calendar.current.date(from: morningComps), morningDate > Date() {
                let trigger = UNCalendarNotificationTrigger(dateMatching: morningComps, repeats: false)
                addRequest(id: "\(id)_morning", content: morningContent, trigger: trigger)
            }
        }
    }
    
    private func addRequest(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification: \(id)")
            }
        }
    }
    
    func cancelNotification(for deadline: Deadline) {
        guard let id = deadline.id else { return }
        // We cancel all potential keys we might have created
        let identifiers = ["\(id)_start", "\(id)_24h", "\(id)_morning"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
