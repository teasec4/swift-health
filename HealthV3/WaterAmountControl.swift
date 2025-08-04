import SwiftUI

struct WaterAmountControl: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    
    @State private var buttonAdd100Pressed: Bool = false
    @State private var buttonAdd250Pressed: Bool = false
    @State private var buttonAdd500Pressed: Bool = false
    @State private var buttonUndoPressed: Bool = false
    
    var body: some View {
        VStack {
            HStack{
                Image(systemName: "drop")
                    .font(.title2)
                    
                Text("Add")
                // Секция воды
                
                // Add 100 ml
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonAdd100Pressed = true
                        waterIntakeManager.addWater(amount: 100)
                        buttonAdd100Pressed = false
                    }
                    print("WaterAmountControl: Added 100 ml")
                }) {
                    Text(NSLocalizedString("100", comment: ""))
                    
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .scaleEffect(buttonAdd100Pressed ? 0.9 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Add 250 ml
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonAdd250Pressed = true
                        waterIntakeManager.addWater(amount: 250)
                        buttonAdd250Pressed = false
                    }
                    print("WaterAmountControl: Added 250 ml")
                }) {
                    Text(NSLocalizedString("250", comment: ""))
                    
                        .foregroundStyle(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .scaleEffect(buttonAdd250Pressed ? 0.9 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
            }
            
            HStack{
                Image(systemName: "arrow.uturn.backward")
                    .font(.title3)
                    .foregroundStyle(.black)
                
                // Undo
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        buttonUndoPressed = true
                        waterIntakeManager.undoLastWaterIntake()
                        buttonUndoPressed = false
                    }
                    print("WaterAmountControl: Undo last action")
                }) {
                    Text("Delete last one")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .scaleEffect(buttonUndoPressed ? 0.9 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
