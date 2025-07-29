import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    

    @State private var selectedStepGoal: Int
    @State private var selectedWaterGoal: Int

    @Environment(\.dismiss) private var dismiss

    init(healthKitManager: HealthKitManager, waterIntakeManager: WaterIntakeManager) {
        self.healthKitManager = healthKitManager
        self.waterIntakeManager = waterIntakeManager
        _selectedStepGoal = State(initialValue: Int(healthKitManager.stepGoal))
        _selectedWaterGoal = State(initialValue: Int(waterIntakeManager.waterGoal))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Step Goal Picker
                    GoalPickerCard(
                        title: "Step Goal",
                        currentValue: "\(Int(healthKitManager.stepGoal)) steps",
                        range: Array(stride(from: 1000, through: 100000, by: 500)),
                        selectedValue: $selectedStepGoal,
                        onSet: { newGoal in
                            healthKitManager.setStepGoal(Double(newGoal))
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
                        }
                    )

                    // Notification Settings
                    NotificationSettingsCard(
                        notificationManager: NotificationManager.shared,
                        healthKitManager: healthKitManager,
                        waterIntakeManager: waterIntakeManager)
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Save goals explicitly (already saved on set)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
