import Combine
import Foundation
import UIKit
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: "notificationsEnabled") {
        didSet {
            print("NotificationManager: notificationsEnabled changed to \(notificationsEnabled)")
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if !notificationsEnabled {
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                print("NotificationManager: Cleared all notifications")
            } else {
                scheduleAllNotifications(
                    steps: healthKitManager?.steps ?? 0.0,
                    stepGoal: healthKitManager?.stepGoal ?? 10000.0,
                    water: waterIntakeManager?.waterIntake ?? 0.0,
                    waterGoal: waterIntakeManager?.waterGoal ?? 2000.0
                )
            }
        }
    }

    @Published var mode: ReminderMode {
        didSet {
            if oldValue != mode {
                UserDefaults.standard.set(mode.rawValue, forKey: "notificationMode")
                print("NotificationManager: Mode changed to \(mode.rawValue)")
                scheduleAllNotifications(
                    steps: healthKitManager?.steps ?? 0.0,
                    stepGoal: healthKitManager?.stepGoal ?? 10000.0,
                    water: waterIntakeManager?.waterIntake ?? 0.0,
                    waterGoal: waterIntakeManager?.waterGoal ?? 2000.0
                )
            }
        }
    }

    private weak var healthKitManager: HealthKitManager?
    private weak var waterIntakeManager: WaterIntakeManager?

    private init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        if let raw = UserDefaults.standard.string(forKey: "notificationMode"),
           let saved = ReminderMode(rawValue: raw) {
            self.mode = saved
            print("NotificationManager: Loaded mode from UserDefaults: \(saved.rawValue)")
        } else {
            self.mode = .rare
            print("NotificationManager: Set default mode: rare")
        }
        checkAuthorizationStatus()
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("NotificationManager: Deinitialized")
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStepsUpdated(_:)),
            name: .stepsUpdated,
            object: nil
        )
    }

    @objc func handleDataReset() {
        print("NotificationManager: Handling data reset")
        guard let healthKitManager = healthKitManager,
              let waterIntakeManager = waterIntakeManager else {
            print("NotificationManager: Managers not set")
            return
        }
        scheduleAllNotifications(
            steps: healthKitManager.steps,
            stepGoal: healthKitManager.stepGoal,
            water: waterIntakeManager.waterIntake,
            waterGoal: waterIntakeManager.waterGoal
        )
    }

    @objc func handleStepsUpdated(_ notification: Notification) {
        guard let steps = notification.userInfo?["steps"] as? Double,
              let healthKitManager = healthKitManager,
              let waterIntakeManager = waterIntakeManager else {
            print("NotificationManager: Invalid steps update or managers not set")
            return
        }
        print("NotificationManager: Received steps update: \(steps)")
        scheduleAllNotifications(
            steps: steps,
            stepGoal: healthKitManager.stepGoal,
            water: waterIntakeManager.waterIntake,
            waterGoal: waterIntakeManager.waterGoal
        )
    }

    func setManagers(healthKitManager: HealthKitManager, waterIntakeManager: WaterIntakeManager) {
        self.healthKitManager = healthKitManager
        self.waterIntakeManager = waterIntakeManager
        print("NotificationManager: Managers set, healthKitManager = \(healthKitManager), waterIntakeManager = \(waterIntakeManager)")
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                print("NotificationManager: Permission request result - \(granted)")
            }
        }
    }

    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
                print("NotificationManager: Authorization status - \(self.notificationsEnabled)")
            }
        }
    }

    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL)
        print("NotificationManager: Opened app settings")
    }

    func scheduleAllNotifications(steps: Double, stepGoal: Double, water: Double, waterGoal: Double) {
        if notificationsEnabled {
            print(
                "NotificationManager: Scheduling notifications with mode \(mode.rawValue), steps: \(steps), stepGoal: \(stepGoal), water: \(water), waterGoal: \(waterGoal)"
            )
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            ReminderScheduler.scheduleReminders(
                mode: mode,
                steps: steps,
                stepGoal: stepGoal,
                water: water,
                waterGoal: waterGoal
            )
        } else {
            print("NotificationManager: Notifications disabled, skipping scheduling")
        }
    }

    func debugPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("NotificationManager: Pending notifications: \(requests.count)")
            for request in requests {
                print("NotificationManager: Notification: \(request.identifier), content: \(request.content.body), trigger: \(String(describing: request.trigger))")
            }
        }
    }
}
