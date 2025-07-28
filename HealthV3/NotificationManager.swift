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
    
    @Published var notificationMode: NotificationMode = UserDefaults.standard.string(forKey: "notificationMode").flatMap { NotificationMode(rawValue: $0) } ?? .rare {
            didSet {
                UserDefaults.standard.set(notificationMode.rawValue, forKey: "notificationMode")
            }
        }

    enum NotificationMode: String {
        case rare = "rare"
        case frequent = "frequent"
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

            switch notificationMode {
            case .rare:
                // Only notify if significantly behind
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

            case .frequent:
                // Schedule regular reminders regardless of progress
                scheduleNotification(
                    id: "morningSteps",
                    title: "🚶‍♂️ Keep moving!",
                    body: "You’ve walked \(Int(steps)) steps. Aim for \(Int(stepGoal)) today!",
                    hour: 10,
                    minute: 0
                )
                scheduleNotification(
                    id: "eveningSteps",
                    title: "🚶‍♂️ Evening check-in",
                    body: "You’re at \(Int(steps)) steps. Keep it up or take a quick walk!",
                    hour: 18,
                    minute: 0
                )
                scheduleNotification(
                    id: "morningWater",
                    title: "💧 Stay hydrated",
                    body: "You’ve had \(Int(water)) ml of water. Keep drinking to reach \(Int(waterGoal)) ml!",
                    hour: 9,
                    minute: 0
                )
                scheduleNotification(
                    id: "afternoonWater",
                    title: "💧 Hydration reminder",
                    body: "You’re at \(Int(water)) ml. Have a glass to stay on track!",
                    hour: 15,
                    minute: 0
                )
            }
        }
    
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Error: Invalid settings URL")
            return
        }
        
        guard UIApplication.shared.canOpenURL(settingsURL) else {
            print("Error: Cannot open settings URL")
            return
        }
        
        UIApplication.shared.open(settingsURL) { success in
            if !success {
                print("Error: Failed to open app settings")
            } else {
                print("Successfully opened app settings")
            }
        }
    }
}
