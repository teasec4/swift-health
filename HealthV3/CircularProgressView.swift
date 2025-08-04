import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let goal: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray.opacity(0.2))

            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: -90))
            
            
            VStack {
                
                Text(String(format: "%.0f%%", min(progress, 1) * 100))
//                    .foregroundColor(color)
                    .font(.headline)
                
                Label {
                    Text("\(Int(goal))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "trophy.fill")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
//                        .foregroundStyle(LinearGradient(
//                            colors: [.yellow, .orange],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ))
                }
                .labelStyle(.titleAndIcon)
                
            }
            

        }
    }
}
