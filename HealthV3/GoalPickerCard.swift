import SwiftUI

struct GoalPickerCard: View {
    let title: String
    let currentValue: String
    let range: [Int]
    @Binding var selectedValue: Int
    let onSet: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(title)")
                .font(.headline)

            Text("Current: \(currentValue)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                

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
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        //        .shadow(radius: 2)
    }
}
