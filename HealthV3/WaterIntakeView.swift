import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0
    @State private var buttonPressed: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            
            ZStack {
                CircularProgressView(progress: animateAmount, color: .cyan)
                    .frame(width: 180, height: 180)
                    .animation(.easeInOut(duration: 0.5), value: animateAmount)

                VStack {
                    Text("\(Int(waterIntakeManager.waterIntake)) ml")
                        .font(.title.bold())
                        .transition(.opacity.combined(with: .scale))
                        .id(waterIntakeManager.waterIntake)
                        .animation(
                            .spring(),
                            value: waterIntakeManager.waterIntake
                        )
                    Text("Drunk Today")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {

                StatCard(
                    title: "Goal",
                    value: "\(Int(waterIntakeManager.waterGoal)) ml"
                )
                .frame(maxWidth: .infinity)

                VStack {
                    Button(action: {
                        withAnimation(
                            .spring(response: 0.3, dampingFraction: 0.6)
                        ) {
                            buttonPressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            buttonPressed = false
                        }

                        waterIntakeManager.addWater(amount: 200)
                    }) {
                        VStack(spacing: 8) {
                            Text("Add 200 ml")
                                .font(.caption)
                                .foregroundStyle(.white)

                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)

                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.cyan)
                        )
                        //                        .shadow(radius: 2)
                        .scaleEffect(buttonPressed ? 0.94 : 1.0)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(maxWidth: .infinity)
                }

            }

            Spacer()
        }
        .padding()
        .onAppear {
            animateAmount =
                waterIntakeManager.waterIntake / waterIntakeManager.waterGoal
        }
        .onChange(of: waterIntakeManager.waterIntake) { newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                animateAmount = newValue / waterIntakeManager.waterGoal
            }
        }
    }

}

#Preview {
    ContentView()
}
