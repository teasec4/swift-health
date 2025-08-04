import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            
                CircularProgressView(progress: animateAmount, color: .cyan, goal: waterIntakeManager.waterGoal)
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut(duration: 0.5), value: animateAmount)

                
            
            WaterAmountControl(waterIntakeManager: waterIntakeManager)


            Spacer()
        }
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
    ContentView()
}
