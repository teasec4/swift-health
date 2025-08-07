import SwiftUI

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    
    
    var body: some View {
        ScrollView {
            Text("Progress")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            InformView(title:"Steps", progress: healthKitManager.steps / healthKitManager.stepGoal , color:.red, goal:healthKitManager.stepGoal, type: "steps", current: healthKitManager.steps, img:"figure.walk", height:180)
            
            InformView(title:"Water", progress:waterIntakeManager.waterIntake / waterIntakeManager.waterGoal, color: .cyan, goal:waterIntakeManager.waterGoal, type: "ml", current: waterIntakeManager.waterIntake, img: "drop.fill", height:180)
            
            Text("Today's Goal")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            VStack(alignment:.trailing, spacing: 24){
                VStack(alignment: .trailing, spacing: 8){
                    Text("\(Int(healthKitManager.stepGoal)) steps")
                        .font(.title2.bold())
                    ProgressView(value:healthKitManager.steps,total: healthKitManager.stepGoal )
                        .progressViewStyle(.linear)
                        .tint(.red)
                        .frame(height: 10)
                                    .clipShape(Capsule())
                }
                VStack(alignment: .trailing, spacing: 8){
                    Text("\(Int(waterIntakeManager.waterGoal)) ml")
                        .font(.title2.bold())
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
            
            
        }
        .navigationTitle("Summary")
        .padding()
    }
}

#Preview {
    ContentView()
}
