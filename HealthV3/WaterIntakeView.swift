import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0
    
    var body: some View {
        VStack(spacing: 24) {
            
            InformView(title:"Water", progress:animateAmount, color: .cyan, goal:waterIntakeManager.waterGoal, type: "ml", current: waterIntakeManager.waterIntake, img: "drop.fill", height: 180)
                .animation(.easeInOut(duration: 0.5), value: animateAmount)
                
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
