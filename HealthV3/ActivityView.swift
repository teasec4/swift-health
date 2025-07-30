import SwiftUI

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                CircularProgressView(
                    progress: healthKitManager.steps
                        / healthKitManager.stepGoal,
                    color: .red
                )
                .frame(width: 180, height: 180)

                VStack {
                    Text("\(Int(healthKitManager.steps))")
                        .font(.largeTitle.bold())
                    Text("Steps")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 20) {
                StatCard(
                    title: "Goal",
                    value: "\(Int(healthKitManager.stepGoal))"
                )
                StatCard(
                    title: "Calories",
                    value: "\(Int(healthKitManager.calories)) kcal"
                )
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
