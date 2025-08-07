import SwiftUI

struct GoalPickerCard: View {
    let title: String
   
    let range: [Int]
    @Binding var selectedValue: Int
    let onSet: (Int) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("\(title)")
                .font(.caption)
            
            Picker("Select", selection: $selectedValue) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            
            .frame(height: 100)
            
            .clipped()
            .onChange(of: selectedValue, perform: onSet)
        }
        
    }
}

#Preview {
    NotificationSettingsView(
        healthKitManager: HealthKitManager(),
        waterIntakeManager: WaterIntakeManager()
    )
}
