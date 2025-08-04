import SwiftUI

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(spacing: 24) {
            
                CircularProgressView(
                    progress: healthKitManager.steps
                        / healthKitManager.stepGoal,
                    color: .red,
                    goal: healthKitManager.stepGoal
                )
                .frame(width: 180, height: 180)
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
