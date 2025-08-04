import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                CircularProgressView(progress: animateAmount, color: .cyan)
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut(duration: 0.5), value: animateAmount)

                VStack {
                    Text(
                        String(
                            format: NSLocalizedString("%6d ml", comment: ""),
                            Int(waterIntakeManager.waterIntake)
                        )
                    )
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .clipped()
                    .animation(nil, value: waterIntakeManager.waterIntake)  // Отключить анимацию текста
                    Label {
                        Text("\(Int(waterIntakeManager.waterGoal)) ml")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } icon: {
                        Image(systemName: "trophy.fill")
                            .font(.subheadline)
                            .foregroundStyle(LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    }
                    .labelStyle(.titleAndIcon)
                    
                }
            }
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
