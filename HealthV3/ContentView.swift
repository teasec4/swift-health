import SwiftUI

struct ContentView: View {

    @StateObject private var waterIntakeManager = WaterIntakeManager()
    @StateObject private var healthKitManager: HealthKitManager
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showWelcome = false

    @State private var activeFullScreen: ActiveFullScreen?

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
        NavigationStack {
            ZStack {
                VStack(spacing:10){
                    Spacer().frame(height: 20) // Отступ сверху для предотвращения прилипания
                    ActivityView(healthKitManager: healthKitManager)
                        
                    
                    WaterIntakeView(waterIntakeManager: waterIntakeManager)
                       
                    
                }
                .padding(.horizontal)
                
            }
            .navigationTitle("Your Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        activeFullScreen = .settings
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        activeFullScreen = .calendar
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .fullScreenCover(item: $activeFullScreen) { item in
                    switch item {
                    case .settings:
                        NotificationSettingsView(
                            healthKitManager: healthKitManager,
                            waterIntakeManager: waterIntakeManager
                        )
                    case .calendar:
                        CalendarView(
                            healthKitManager: healthKitManager,
                            waterIntakeManager: waterIntakeManager
                        )
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
                }

            //            .sheet(isPresented: $showSettings) {
            //                NotificationSettingsView(
            //                    healthKitManager: healthKitManager,
            //                    waterIntakeManager: waterIntakeManager
            //                )
            //            }
            //            .sheet(isPresented: $showCalendar) {
            //                CalendarView(
            //                    healthKitManager: healthKitManager,
            //                    waterIntakeManager: waterIntakeManager
            //                )
            //                .presentationDetents([.large])
            //                .presentationDragIndicator(.visible)
            //            }

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

enum ActiveFullScreen: Int, Identifiable {
    case settings, calendar
    var id: Int { rawValue }
}

#Preview {
    ContentView()
}
