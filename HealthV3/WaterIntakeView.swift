import SwiftUI

struct WaterIntakeView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var animateAmount: Double = 0
    @State private var buttonAddPressed: Bool = false
    @State private var buttonRemovePressed: Bool = false
    @State private var waterAmount: Double = 200  // Значение слайдера по умолчанию

    private let waterAmounts = Array(
        stride(from: 0.0, through: 1000.0, by: 50.0)
    )  // [0, 50, 100, ..., 1000]

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
                    Text(NSLocalizedString("Drunk Today", comment: ""))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                StatCard(
                    title: NSLocalizedString("Goal", comment: ""),
                    value: String(
                        format: NSLocalizedString("%6d ml", comment: ""),
                        Int(waterIntakeManager.waterGoal)
                    )
                )
                .frame(maxWidth: .infinity)

                // Пикер и кнопки
                HStack {
                    Picker(
                        selection: $waterAmount,
                        label: Text("Amount").foregroundColor(.clear)
                    ) {
                        ForEach(waterAmounts, id: \.self) { amount in
                            Text(
                                String(
                                    format: NSLocalizedString(
                                        "%d ml",
                                        comment: ""
                                    ),
                                    Int(amount)
                                )
                            )
                            .tag(amount)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)  // Ограничить высоту для компактности
                    .clipped()

                    VStack {
                        Spacer()
                        Button(action: {
                            withAnimation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                            ) {
                                buttonRemovePressed = true
                                waterIntakeManager.addWater(
                                    amount: -waterAmount
                                )
                                buttonRemovePressed = false
                            }
                            print("WaterIntakeView: Removed \(waterAmount) ml")
                        }) {

                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.black)

                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .scaleEffect(buttonRemovePressed ? 0.94 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            withAnimation(
                                .spring(response: 0.3, dampingFraction: 0.6)
                            ) {
                                buttonAddPressed = true
                                waterIntakeManager.addWater(amount: waterAmount)
                                buttonAddPressed = false
                            }
                            print("WaterIntakeView: Added \(waterAmount) ml")
                        }) {

                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.cyan)

                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .scaleEffect(buttonAddPressed ? 0.94 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }

                    .frame(maxWidth: .infinity)

                }
            }

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
