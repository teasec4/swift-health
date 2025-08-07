import SwiftUI

struct ContentView: View {
    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @StateObject private var healthKitManager: HealthKitManager
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showWelcome = false
    @State private var showSettings = false
    
    // Публичный инициализатор для #Preview
    public init() {
        let waterIntakeManager = WaterIntakeManager()
        self._waterIntakeManager = StateObject(wrappedValue: waterIntakeManager)
        self._healthKitManager = StateObject(
            wrappedValue: HealthKitManager(
                waterIntakeManager: waterIntakeManager
            )
        )
    }
    
    var body: some View {
        TabView {
            NavigationStack{
                ActivityView(healthKitManager: healthKitManager, waterIntakeManager:waterIntakeManager)
            }
                .tabItem{
                    Label("Summary", systemImage: "heart")
                }
            
            NavigationStack{
                WaterIntakeView(waterIntakeManager: waterIntakeManager)
            }
                .tabItem{
                    Label("Water Intake", systemImage: "drop")
                }
            
            NavigationStack{
                CalendarView(
                    healthKitManager: healthKitManager,
                    waterIntakeManager: waterIntakeManager
                )
            }
            .tabItem{
                Label("Calendar", systemImage: "calendar")
            }
            
            NavigationStack{
                NotificationSettingsView(
                    healthKitManager: healthKitManager,
                    waterIntakeManager: waterIntakeManager
                )
            }
            .tabItem{
                Label("Settings", systemImage: "gear")
            }
        }
    
        
        .sheet(
            isPresented: $showWelcome,
            onDismiss: {
                // Устанавливаем флаг после закрытия WelcomeView
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                showWelcome = false
                print(
                    "ContentView: WelcomeView dismissed, set hasLaunchedBefore to true"
                )
            }
        ) {
            WelcomeView()
                .transition(.opacity)
                .animation(.easeInOut, value: showWelcome)
        }
        
        
        .onAppear {
            // Проверяем, был ли первый запуск
            let hasLaunchedBefore = UserDefaults.standard.bool(
                forKey: "hasLaunchedBefore"
            )
            print("ContentView: hasLaunchedBefore = \(hasLaunchedBefore)")
            showWelcome = !hasLaunchedBefore
            
            healthKitManager.requestAuthorization()
            notificationManager.setManagers(
                healthKitManager: healthKitManager,
                waterIntakeManager: waterIntakeManager
            )
            waterIntakeManager.resetIfNewDay()
            healthKitManager.resetIfNewDay()
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
