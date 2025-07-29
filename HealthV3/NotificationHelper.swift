import Foundation
import UserNotifications

enum NotificationHelper {
    static func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification '\(id)': \(error.localizedDescription)")
            } else {
                print("📅 Scheduled notification '\(id)' at \(hour):\(minute)")
            }
        }
    }

    static func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
