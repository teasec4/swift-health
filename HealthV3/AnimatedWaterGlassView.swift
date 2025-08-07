import SwiftUI

struct AnimatedWaterGlassView: View {
    var progress: Double // 0.0 to 1.0
    var color: Color = .cyan

    @State private var bubbleOffsets: [CGFloat] = (0..<10).map { _ in CGFloat.random(in: 0...1) }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let waterHeight = height * progress

            ZStack(alignment: .bottom) {
                // Glass shape
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 4)

                // Water fill
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.6))
                    .frame(height: waterHeight)
                    .animation(.easeInOut(duration: 0.5), value: progress)

                // Bubbles
                ForEach(0..<10, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.7))
                        .frame(width: 6, height: 6)
                        .offset(
                            x: CGFloat.random(in: -width/3...width/3),
                            y: -CGFloat(bubbleOffsets[index]) * waterHeight
                        )
                        .animation(
                            Animation.linear(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: false),
                            value: bubbleOffsets[index]
                        )
                }
            }
            .onAppear {
                // Randomly animate bubbles
                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                    withAnimation {
                        bubbleOffsets = (0..<10).map { _ in CGFloat.random(in: 0...1) }
                    }
                }
            }
        }
        .aspectRatio(0.6, contentMode: .fit)
    }
}
