import Foundation
import UserNotifications
import UIKit
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet {
            print("NotificationManager: notificationsEnabled changed to \(notificationsEnabled)")
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if !notificationsEnabled {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("NotificationManager: Cleared all notifications")
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                print("NotificationManager: Permission request result - \(granted)")
            }
        }
    }

    @Published var mode: ReminderMode {
        didSet {
            if oldValue != mode { // Проверяем, изменился ли режим
                UserDefaults.standard.set(mode.rawValue, forKey: "notificationMode")
                print("NotificationManager: Mode changed to \(mode.rawValue)")
                }
            }
        }
    
    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        print("NotificationManager: Initialized with notificationsEnabled")
        if let raw = UserDefaults.standard.string(forKey: "notificationMode"),
           let saved = ReminderMode(rawValue: raw) {
            self.mode = saved
            print("Loaded mode from UserDefaults: \(saved.rawValue)")
        } else {
            self.mode = .rare
            print("Set default mode: rare")
        }
        checkAuthorizationStatus()
    }
    
    


    

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
            }
        }
    }


    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL)
    }
    
    func scheduleAllNotifications(steps: Double, stepGoal: Double, water: Double, waterGoal: Double) {
            print("NotificationManager: Scheduling notifications with mode \(mode.rawValue), steps: \(steps), stepGoal: \(stepGoal), water: \(water), waterGoal: \(waterGoal)")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            ReminderScheduler.scheduleReminders(mode: mode, steps: steps, stepGoal: stepGoal, water: water, waterGoal: waterGoal)
        }
}
