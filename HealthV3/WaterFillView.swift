import SwiftUI

struct WaterFillView: View {
    var progress: Double // от 0 до 1
    var color: Color = .cyan
    var goal: Double
    var current: Double
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let fillHeight = height * progress

            ZStack(alignment: .bottom) {
                Circle()
                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 4)
                    .background(Circle().fill(Color.white))
                
                Circle()
                    .clipShape(Rectangle().offset(y: height - fillHeight))
                    .foregroundColor(color.opacity(0.6))
                Text("\(Int(current)) / \(Int(goal))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .zIndex(1)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}
