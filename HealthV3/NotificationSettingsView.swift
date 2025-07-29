import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var selectedStepGoal: Int
    @State private var selectedWaterGoal: Int
    @Environment(\.dismiss) private var dismiss
    @State private var toastMessage: String? = nil
    @State private var isShowingToast = false
    @State private var isSuccessToast = false // Для различия успеха и неуспеха

    init(healthKitManager: HealthKitManager, waterIntakeManager: WaterIntakeManager) {
        self.healthKitManager = healthKitManager
        self.waterIntakeManager = waterIntakeManager
        _selectedStepGoal = State(initialValue: Int(healthKitManager.stepGoal))
        _selectedWaterGoal = State(initialValue: Int(waterIntakeManager.waterGoal))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 32) {
                    // Step Goal Picker
                    GoalPickerCard(
                        title: "Step Goal",
                        currentValue: "\(Int(healthKitManager.stepGoal)) steps",
                        range: Array(stride(from: 1000, through: 100000, by: 500)),
                        selectedValue: $selectedStepGoal,
                        onSet: { newGoal in
                            healthKitManager.setStepGoal(Double(newGoal))
                            toastMessage = "Step goal has been updated!"
                            isShowingToast = true
                            isSuccessToast = true
                        }
                    )

                    // Water Goal Picker
                    GoalPickerCard(
                        title: "Water Goal",
                        currentValue: "\(Int(waterIntakeManager.waterGoal)) ml",
                        range: Array(stride(from: 500, through: 10000, by: 200)),
                        selectedValue: $selectedWaterGoal,
                        onSet: { newGoal in
                            waterIntakeManager.setWaterGoal(Double(newGoal))
                            toastMessage = "Water goal has been updated!"
                            isShowingToast = true
                            isSuccessToast = true
                        }
                    )

                    // Notification Settings
                    NotificationSettingsCard(
                        notificationManager: NotificationManager.shared,
                        healthKitManager: healthKitManager,
                        waterIntakeManager: waterIntakeManager,
                        onSave: {
                            toastMessage = "Notification settings saved successfully!"
                            isShowingToast = true
                            isSuccessToast = true
                        },
                        onCancel: {
                            toastMessage = "Notification changes were not saved."
                            isShowingToast = true
                            isSuccessToast = false
                        }
                    )
                    .padding()
                    
                    Spacer()
                }

                // Toast pushup
                if isShowingToast {
                    VStack {
                        Spacer()
                        Text(toastMessage ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(isSuccessToast ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 5)
                            .padding(.bottom, 20)
                            .transition(.move(edge: .bottom))
                            .onAppear {
                                // Автоматическое исчезновение через 1 секунды
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        toastMessage = "Changes were not saved."
                        isShowingToast = true
                        isSuccessToast = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        toastMessage = "Settings saved successfully!"
                        isShowingToast = true
                        isSuccessToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            dismiss()
                        }
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
