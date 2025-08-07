import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            
//                InformView(title:"Water", progress:animateAmount, color: .cyan, goal:waterIntakeManager.waterGoal, type: "ml", current: waterIntakeManager.waterIntake, img: "drop.fill", height: 180)
//                    .animation(.easeInOut(duration: 0.5), value: animateAmount)
            Text("Progress")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack{
                
                HStack{
                    Text("\(Int(waterIntakeManager.waterIntake)) ml")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(waterIntakeManager.waterGoal)) ml")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        
                }
                ProgressView(value: waterIntakeManager.waterIntake, total: waterIntakeManager.waterGoal)
                    .tint(.cyan)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer()
            
                
            AnimatedWaterGlassView(progress: animateAmount)
                
            
            WaterAmountControl(waterIntakeManager: waterIntakeManager)
           
            
            
            Spacer()
        }
        .navigationTitle("Water Intake")
        .padding()
        .onAppear {
            animateAmount =
            waterIntakeManager.waterIntake / waterIntakeManager.waterGoal
            print(
                "WaterIntakeView: onAppear, waterIntake = \(waterIntakeManager.waterIntake), animateAmount = \(animateAmount)"
            )
        }
        .onChange(of: waterIntakeManager.waterIntake) { newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                animateAmount = newValue / waterIntakeManager.waterGoal
            }
            print("WaterIntakeView: waterIntake changed to \(newValue)")
        }
    }
}

#Preview {
    WaterIntakeView(waterIntakeManager: WaterIntakeManager())
}
