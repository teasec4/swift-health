import SwiftUI

struct ContentView: View {
    
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @ObservedObject var notificationManager = NotificationManager.shared
        
    var body: some View {
        NavigationView{
            TabView{
                ActivityView(healthKitManager: healthKitManager)
                    .tabItem {
                        Label("Activity", systemImage: "figure.walk")
                    }
                    .tint(.red)
                
                WaterIntakeView(waterIntakeManager: waterIntakeManager)
                    .tabItem{
                        Label("Water", systemImage: "drop.fill")
                    }
                SettingsView(healthKitManager: healthKitManager, waterIntakeManager: waterIntakeManager)
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                
            }
        
            .navigationTitle("Your Health")
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        .onAppear {
            healthKitManager.requestAuthorization()
            notificationManager.scheduleSmartReminders(
                steps: healthKitManager.steps,
                stepGoal: healthKitManager.stepGoal,
                water: waterIntakeManager.waterIntake,
                waterGoal: waterIntakeManager.waterGoal
            )

        }
    }
}

#Preview {
    ContentView()
}
