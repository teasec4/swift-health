import SwiftUI

struct GoalPickerCard: View {
    let title: String
   
    let range: [Int]
    @Binding var selectedValue: Int
    let onSet: (Int) -> Void

    var body: some View {
        HStack{
            Text("\(title)")
                
            Spacer()
//            Image(systemName: "trophy")
            Picker("", selection: $selectedValue) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedValue, perform: onSet)
        }
        
    }
}


