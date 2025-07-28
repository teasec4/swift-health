import SwiftUI

struct SettingsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    
    @State private var selectedStepGoal: Int
    @State private var selectedWaterGoal: Int
    
    init(healthKitManager: HealthKitManager, waterIntakeManager: WaterIntakeManager) {
            self.healthKitManager = healthKitManager
            self.waterIntakeManager = waterIntakeManager
            _selectedStepGoal = State(initialValue: Int(healthKitManager.stepGoal))
            _selectedWaterGoal = State(initialValue: Int(waterIntakeManager.waterGoal))
        }

    var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    GoalPickerCard(
                        title: "Step Goal",
                        currentValue: "\(Int(healthKitManager.stepGoal)) steps",
                        range: Array(stride(from: 1000, through: 100000, by: 500)),
                        selectedValue: $selectedStepGoal,
                        onSet: { newGoal in
                            healthKitManager.setStepGoal(Double(newGoal))
                        }
                    )

                    GoalPickerCard(
                        title: "Water Goal",
                        currentValue: "\(Int(waterIntakeManager.waterGoal)) ml",
                        range: Array(stride(from: 500, through: 10000, by: 200)),
                        selectedValue: $selectedWaterGoal,
                        onSet: { newGoal in
                            waterIntakeManager.setWaterGoal(Double(newGoal))
                        }
                    )
                }
                .padding()
            }
        }
    }


#Preview {
    ContentView()
}

