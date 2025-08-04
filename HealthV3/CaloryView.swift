import SwiftUI

struct CaloryView: View {
    
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    
    var body: some View {
        HStack{
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "flame")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("\(Int(healthKitManager.calories))")
                    
                
                Text("kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4) // Выравнивание по базовой линии
            }
            .padding()
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "figure.walk")
                    .font(.title3)
                    .foregroundColor(.red)
                
                Text("\(Int(healthKitManager.steps))")
                    
                
                Text("step")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4) // Выравнивание по базовой линии
            }
            .padding()
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundColor(.cyan)
                
                Text("\(Int(waterIntakeManager.waterIntake))")
                    
                
                Text("ml")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4) // Выравнивание по базовой линии
            }
            .padding()
        }
        
    }
}
