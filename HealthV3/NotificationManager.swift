import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")

            if notificationsEnabled {
                requestPermission()
            } else {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        }
    }

    private init() {
        checkAuthorizationStatus()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if !granted {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    self.notificationsEnabled = false
                }
            }
        }
    }

    func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        guard notificationsEnabled else { return }

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func scheduleSmartReminders(steps: Double, stepGoal: Double, water: Double, waterGoal: Double) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        if steps < stepGoal * 0.25 {
            scheduleNotification(
                id: "lowSteps",
                title: "🚶‍♂️ Time to move!",
                body: "You’ve only walked \(Int(steps)) steps. Get up and move!",
                hour: 12,
                minute: 0
            )
        }

        if water < waterGoal * 0.3 {
            scheduleNotification(
                id: "lowWater",
                title: "💧 Stay hydrated",
                body: "You’ve only had \(Int(water)) ml of water today. Take a sip!",
                hour: 16,
                minute: 0
            )
        }
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
