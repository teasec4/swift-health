import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var selectedStepGoal: Int
    @State private var selectedWaterGoal: Int
    @State private var tempNotificationsEnabled: Bool
    @State private var tempMode: ReminderMode
    
    @State private var toastMessage: String? = nil
    @State private var isShowingToast = false
    @State private var isSuccessToast = false
    
    init(
        healthKitManager: HealthKitManager,
        waterIntakeManager: WaterIntakeManager
    ) {
        self.healthKitManager = healthKitManager
        self.waterIntakeManager = waterIntakeManager
        _selectedStepGoal = State(initialValue: Int(healthKitManager.stepGoal))
        _selectedWaterGoal = State(
            initialValue: Int(waterIntakeManager.waterGoal)
        )
        _tempNotificationsEnabled = State(
            initialValue: NotificationManager.shared.notificationsEnabled
        )
        _tempMode = State(initialValue: NotificationManager.shared.mode)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 15){
                        Text("Goals")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        HStack{
                            // Step Goal Picker
                            GoalPickerCard(
                                title: "Step",
                                range: Array(
                                    stride(from: 1000, through: 100000, by: 500)
                                ),
                                selectedValue: $selectedStepGoal,
                                onSet: { newGoal in
                                    // Обновляем только временное значение
                                    selectedStepGoal = newGoal
                                }
                            )
                            // Water Goal Picker
                            GoalPickerCard(
                                title: "Water",
                                range: Array(
                                    stride(from: 500, through: 10000, by: 200)
                                ),
                                selectedValue: $selectedWaterGoal,
                                onSet: { newGoal in
                                    // Обновляем только временное значение
                                    selectedWaterGoal = newGoal
                                }
                            )
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 15){
                        Text("Remainder")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        // Notification Settings
                        NotificationSettingsCard(
                            notificationManager: NotificationManager.shared,
                            healthKitManager: healthKitManager,
                            waterIntakeManager: waterIntakeManager,
                            tempNotificationsEnabled: $tempNotificationsEnabled,
                            tempMode: $tempMode,
                            onSave: {
                                toastMessage =
                                "Notification settings saved successfully!"
                                isShowingToast = true
                                isSuccessToast = true
                            },
                            onCancel: {
                                toastMessage =
                                "Notification changes were not saved."
                                isShowingToast = true
                                isSuccessToast = false
                            }
                        )
                    }
                    
                    
                    Spacer()
                }
                .padding()
                
                // Toast pushup
                if isShowingToast {
                    VStack {
                        Spacer()
                        HStack {
                            Image(
                                systemName: isSuccessToast
                                ? "checkmark.circle.fill"
                                : "xmark.circle.fill"
                            )
                            .foregroundColor(.white)
                            Text(toastMessage ?? "")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            isSuccessToast
                            ? Color.green.opacity(0.8)
                            : Color.red.opacity(0.8)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                        .padding(.bottom, 20)
                        .transition(
                            .move(edge: .bottom).combined(with: .opacity)
                        )
                        .onAppear {
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.5
                            ) {
                                withAnimation {
                                    isShowingToast = false
                                }
                            }
                        }
                    }
                    .zIndex(1)
                }
            }
            .navigationTitle("Settings")
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        selectedStepGoal = Int(healthKitManager.stepGoal)
                        selectedWaterGoal = Int(waterIntakeManager.waterGoal)
                        tempNotificationsEnabled = NotificationManager.shared.notificationsEnabled
                        tempMode = NotificationManager.shared.mode
                        
                        toastMessage = "Changes reverted."
                        isShowingToast = true
                        isSuccessToast = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Применяем изменения только при нажатии "Save"
                        healthKitManager.setStepGoal(Double(selectedStepGoal))
                        waterIntakeManager.setWaterGoal(
                            Double(selectedWaterGoal)
                        )
                        NotificationManager.shared.notificationsEnabled =
                        tempNotificationsEnabled
                        NotificationManager.shared.mode = tempMode
                        NotificationManager.shared.scheduleAllNotifications(
                            steps: healthKitManager.steps,
                            stepGoal: healthKitManager.stepGoal,
                            water: waterIntakeManager.waterIntake,
                            waterGoal: waterIntakeManager.waterGoal
                        )
                        toastMessage = "Settings saved successfully!"
                        isShowingToast = true
                        isSuccessToast = true
                        
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .animation(.easeInOut, value: isShowingToast)
        }
    }
}

#Preview {
    
    
    NotificationSettingsView(
        healthKitManager: HealthKitManager(),
        waterIntakeManager: WaterIntakeManager()
        
    )
}
