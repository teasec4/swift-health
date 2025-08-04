import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Запрос разрешения на уведомления
        NotificationManager.shared.requestPermission()
        // Регистрация фоновых задач
        registerBackgroundTasks()
        // Планирование фоновых задач
        scheduleAppRefresh()
        scheduleHealthUpdate()
        print("AppDelegate: Initialized with notification permission request and background tasks setup")
        return true
    }

    private func registerBackgroundTasks() {
        // Регистрация задачи для сброса данных
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourapp.resetData",
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        print("AppDelegate: Registered resetData task")

        // Регистрация задачи для обновления шагов
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourapp.healthUpdate",
            using: nil
        ) { task in
            self.handleHealthUpdateTask(task: task as! BGAppRefreshTask)
        }
        print("AppDelegate: Registered healthUpdate task")
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.resetData")
        request.earliestBeginDate = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Calendar.current.startOfDay(for: Date())
        )
        do {
            try BGTaskScheduler.shared.submit(request)
            print("AppDelegate: Scheduled resetData task for \(String(describing: request.earliestBeginDate))")
        } catch {
            print("AppDelegate: Failed to schedule resetData task: \(error)")
        }
    }

    func scheduleHealthUpdate() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.healthUpdate")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Каждые 15 минут
        do {
            try BGTaskScheduler.shared.submit(request)
            print("AppDelegate: Scheduled healthUpdate task for \(String(describing: request.earliestBeginDate))")
        } catch {
            print("AppDelegate: Failed to schedule healthUpdate task: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Планируем следующую задачу сброса
        scheduleAppRefresh()

        // Создаём экземпляры менеджеров
        let waterIntakeManager = WaterIntakeManager()
        let healthKitManager = HealthKitManager(waterIntakeManager: waterIntakeManager)
        let notificationManager = NotificationManager.shared

        // Устанавливаем зависимости
        notificationManager.setManagers(
            healthKitManager: healthKitManager,
            waterIntakeManager: waterIntakeManager
        )

        // Выполняем сброс данных
        waterIntakeManager.resetIfNewDay()
        healthKitManager.resetIfNewDay()

        // Обновляем уведомления
        notificationManager.scheduleAllNotifications(
            steps: healthKitManager.steps,
            stepGoal: healthKitManager.stepGoal,
            water: waterIntakeManager.waterIntake,
            waterGoal: waterIntakeManager.waterGoal
        )

        task.setTaskCompleted(success: true)
        print("AppDelegate: resetData task completed")
    }

    private func handleHealthUpdateTask(task: BGAppRefreshTask) {
        // Планируем следующую задачу обновления
        scheduleHealthUpdate()

        // Создаём экземпляры менеджеров
        let waterIntakeManager = WaterIntakeManager()
        let healthKitManager = HealthKitManager(waterIntakeManager: waterIntakeManager)
        let notificationManager = NotificationManager.shared

        // Устанавливаем зависимости
        notificationManager.setManagers(
            healthKitManager: healthKitManager,
            waterIntakeManager: waterIntakeManager
        )

        // Обновляем данные шагов и калорий
        healthKitManager.fetchSteps()
        healthKitManager.fetchCalories()

        // Обновляем уведомления
        notificationManager.scheduleAllNotifications(
            steps: healthKitManager.steps,
            stepGoal: healthKitManager.stepGoal,
            water: waterIntakeManager.waterIntake,
            waterGoal: waterIntakeManager.waterGoal
        )

        task.setTaskCompleted(success: true)
        print("AppDelegate: healthUpdate task completed")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
        scheduleHealthUpdate()
        print("AppDelegate: Application entered background")
    }
}
