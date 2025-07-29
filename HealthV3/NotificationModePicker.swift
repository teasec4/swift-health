//
//  NotificationModePicker.swift
//  HealthV3
//
//  Created by Максим Ковалев on 7/29/25.
//
import SwiftUI
import SwiftData

struct NotificationModePicker: View {
    @Binding var selectedMode: ReminderMode
    
    var body: some View {
        HStack(spacing: 16) {
            Picker("Notification Frequency", selection: $selectedMode) {
                    ForEach(ReminderMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue.capitalized).tag(mode)
                        }
            }
            .pickerStyle(SegmentedPickerStyle())
//            .pickerStyle(MenuPickerStyle())
//            .animation(nil, value: selectedMode) // Отключаем анимацию
            .onChange(of: selectedMode) { newMode in
                            print("Picker selected mode: \(newMode.rawValue)") // Отладка
                        }
        }
    }
}
