import SwiftUI

struct ContentView: View {
    
    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @StateObject private var healthKitManager: HealthKitManager
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showSettings = false
    @State private var showCalendar = false
    @State private var showWelcome = false
    
    // Публичный инициализатор для #Preview
    public init() {
        let waterIntakeManager = WaterIntakeManager()
        self._waterIntakeManager = StateObject(wrappedValue: waterIntakeManager)
        self._healthKitManager = StateObject(wrappedValue: HealthKitManager(waterIntakeManager: waterIntakeManager))
    }
    
    
    var body: some View {
        NavigationStack{
            TabView{
                ActivityView(healthKitManager: healthKitManager)
                    .tabItem {
                        Label("Activity", systemImage: "figure.walk")
                    }
    
                
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
                ToolbarItem(placement:.navigationBarLeading){
                    Button{
                        showCalendar = true
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
                }
            
            .sheet(isPresented: $showSettings) {
                    NotificationSettingsView(
                                healthKitManager: healthKitManager,
                                waterIntakeManager: waterIntakeManager
                            )
            }
            .sheet(isPresented: $showCalendar) {
                    CalendarView(
                        healthKitManager: healthKitManager, waterIntakeManager: waterIntakeManager
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            
            .sheet(isPresented: $showWelcome, onDismiss: {
                // Устанавливаем флаг после закрытия WelcomeView
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                showWelcome = false
                print("ContentView: WelcomeView dismissed, set hasLaunchedBefore to true")
                        }) {
                WelcomeView()
                    .transition(.opacity)
                    .animation(.easeInOut, value: showWelcome)
            }
        }
        
        .onAppear {
            // Проверяем, был ли первый запуск
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
            print("ContentView: hasLaunchedBefore = \(hasLaunchedBefore)")
            showWelcome = !hasLaunchedBefore
            
            healthKitManager.requestAuthorization()
            notificationManager.setManagers(healthKitManager: healthKitManager, waterIntakeManager: waterIntakeManager)
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
