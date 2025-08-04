import SwiftUI

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        VStack(spacing: 24) {
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
                    
                        Label {
                            Text("\(Int(healthKitManager.stepGoal))")
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

                        
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
