import SwiftUI

struct CalendarView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var selectedDate: Date = Date()
    @State private var steps: Double = 0
    @State private var water: Double = 0

    var body: some View {
        
            ScrollView{
                VStack (spacing: 24){
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            
                    )
                    .padding(.horizontal)
                    VStack (spacing: 16){
                        InformView(title:"Steps", progress: healthKitManager.steps / healthKitManager.stepGoal , color:.red, goal:healthKitManager.stepGoal, type: "steps", current: steps, img:"figure.walk", height: 150)
                        
                        InformView(title:"Water", progress:waterIntakeManager.waterIntake / waterIntakeManager.waterGoal, color: .cyan, goal:waterIntakeManager.waterGoal, type: "ml", current: water, img: "drop.fill", height: 150)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Calendar")
            .scrollBounceBehavior(.basedOnSize) // (iOS 17+ only)
            
            .onChange(of: selectedDate) { newDate in
                updateData(for: newDate)
            }
            .onAppear {
                updateData(for: selectedDate)
            }
        
    }

    private func updateData(for date: Date) {
        healthKitManager.fetchSteps(for: date) { steps in
            self.steps = steps
            print("CalendarView: Fetched steps for \(date): \(steps)")
        }
        water = waterIntakeManager.waterIntake(for: date)
        print("CalendarView: Fetched water for \(date): \(water)")
    }
}


#Preview {
    CalendarView(
        healthKitManager: HealthKitManager(
            waterIntakeManager: WaterIntakeManager()
        ),
        waterIntakeManager: WaterIntakeManager()
    )
}
