import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Запрос разрешения на уведомления
        NotificationManager.shared.requestPermission()
        // Регистрация фоновой задачи
        registerBackgroundTask()
        // Планирование фоновой задачи
        scheduleAppRefresh()
        print("AppDelegate: Initialized with notification permission request and background task setup")
        return true
    }
    
    private func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.yourapp.resetData", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        print("AppDelegate: Registered background task")
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.resetData")
        request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
        do {
            try BGTaskScheduler.shared.submit(request)
            print("AppDelegate: Scheduled background task for \(String(describing: request.earliestBeginDate))")
        } catch {
            print("AppDelegate: Failed to schedule background task: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Планируем следующую задачу
        scheduleAppRefresh()
        
        // Создаём экземпляры менеджеров
        let waterIntakeManager = WaterIntakeManager()
        let healthKitManager = HealthKitManager(waterIntakeManager: waterIntakeManager)
        let notificationManager = NotificationManager.shared
        
        // Устанавливаем зависимости
        notificationManager.setManagers(healthKitManager: healthKitManager, waterIntakeManager: waterIntakeManager)
        
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
        print("AppDelegate: Background task completed")
    }
}
