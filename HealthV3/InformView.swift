//
//  InformView.swift
//  HealthV3
//
//  Created by Максим Ковалев on 8/7/25.
//
import SwiftUI


struct InformView : View {
    
    let title: String
    let progress: Double
    let color: Color
    let goal: Double
    let type: String
    let current: Double
    let img: String
    let height: CGFloat
    
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "\(img)")
                        .font(.headline)
                    Text("\(title)")
                        .font(.headline)
                    
                }
                .foregroundStyle(color)
                
                Spacer()
                HStack(alignment: .firstTextBaseline, spacing: 4){
                    Text("\(Int(current))")
                        .font(.title)
                    Text("\(type)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                }
                
            }
            Spacer()
            VStack(alignment: .trailing){
                Text("\(Int(current)) / \(Int(goal))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                ZStack{
                    Circle()
                        .stroke(lineWidth: 10)
                        .foregroundColor(.gray.opacity(0.2))
                    
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: -90))
                    VStack{
                        Text(String(format: "%.0f%%", min(progress, 1) * 100))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            
                    }
                }
                .padding(.vertical)
                
            }
            
            
        }
        .padding()
        .frame(height: height)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}


