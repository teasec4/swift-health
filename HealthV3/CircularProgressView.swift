import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let goal: Double
    @State private var symbolEffectTrigger: Int = 0
    @State private var isColored: Bool = false
    
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
                    ZStack{
                        Image(systemName: "trophy.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .opacity(isColored ? 0 : 1)
                        
                        Image(systemName: "trophy.fill")
                            .font(.subheadline)
                            .foregroundStyle(LinearGradient(
                                colors: [.yellow, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .symbolEffect(
                                .variableColor.iterative,
                                options: .nonRepeating,
                                value: symbolEffectTrigger
                            )
                            .opacity(isColored ? 1 : 0)
                    }
                }
                .labelStyle(.titleAndIcon)
                
            }
            
            
        }
        
        .onReceive(NotificationCenter.default.publisher(for: .waterIntakeUpdated)) { _ in
            withAnimation {
                isColored = true
                symbolEffectTrigger += 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isColored = false
                }
            }
            print("CircularProgressView: Triggered variableColor effect, trigger = \(symbolEffectTrigger)")
        }
    }
}
