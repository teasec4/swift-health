import SwiftUI

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var chartUpdateTrigger: Int = 0
    
    var body: some View {
        ScrollView {
            Text("Progress")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack{
                InformView(title:"Steps", progress: healthKitManager.steps / healthKitManager.stepGoal , color:.red, goal:healthKitManager.stepGoal, type: "steps", current: healthKitManager.steps, img:"figure.walk", height:150)
                
                InformView(title:"Water", progress:waterIntakeManager.waterIntake / waterIntakeManager.waterGoal, color: .cyan, goal:waterIntakeManager.waterGoal, type: "ml", current: waterIntakeManager.waterIntake, img: "drop.fill", height:150)
            }
            
            Text("Today's Goal")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment:.trailing, spacing: 24){
                VStack(alignment: .trailing, spacing: 8){
                    Text("\(Int(healthKitManager.stepGoal)) steps")
                        .font(.headline)
                    ProgressView(value:healthKitManager.steps,total: healthKitManager.stepGoal )
                        .progressViewStyle(.linear)
                        .tint(.red)
                        .frame(height: 10)
                        .clipShape(Capsule())
                }
                VStack(alignment: .trailing, spacing: 8){
                    Text("\(Int(waterIntakeManager.waterGoal)) ml")
                        .font(.headline)
                    ProgressView(value: waterIntakeManager.waterIntake, total: waterIntakeManager.waterGoal)
                        .progressViewStyle(.linear)
                        .tint(.cyan)
                        .frame(height: 10)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text("Water Weekly Intake")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            WeeklyChartView(waterIntakeManager: waterIntakeManager)
                .id(chartUpdateTrigger)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
        }
        .navigationTitle("Summary")
        .padding()
    }
}

#Preview {
    ContentView()
}
