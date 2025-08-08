import SwiftUI

@main
struct HealthV3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @StateObject private var healthKitManager: HealthKitManager
    @ObservedObject var notificationManager = NotificationManager.shared
    
    init() {
            let waterIntakeManager = WaterIntakeManager()
            self._waterIntakeManager = StateObject(wrappedValue: waterIntakeManager)
            self._healthKitManager = StateObject(wrappedValue: HealthKitManager(waterIntakeManager: waterIntakeManager))
            print("HealthV3App: Initialized with waterIntakeManager = \(waterIntakeManager), healthKitManager = \(healthKitManager)")
        }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(waterIntakeManager)
                .environmentObject(healthKitManager)
                .environmentObject(notificationManager)
//                .preferredColorScheme(.light)
        }
    }
}
