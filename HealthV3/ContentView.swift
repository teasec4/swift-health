import SwiftUI

struct ContentView: View {
    
    @StateObject private var healthKitManager = HealthKitManager(waterIntakeManager: WaterIntakeManager())
    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @ObservedObject var notificationManager = NotificationManager.shared
    
    @State private var showSettings = false
        
    var body: some View {
        NavigationStack{
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
                
            }
        
            .navigationTitle("Your Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    showSettings = true
                                } label: {
                                    Image(systemName: "gear")
                                }
                            }
                        }
            
            .sheet(isPresented: $showSettings) {
                            NotificationSettingsView(
                                healthKitManager: healthKitManager,
                                waterIntakeManager: waterIntakeManager
                            )
                        }
            
        }
        
        .onAppear {
            healthKitManager.requestAuthorization()
            notificationManager.scheduleAllNotifications(
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
