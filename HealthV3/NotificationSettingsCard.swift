import SwiftUI

struct NotificationSettingsCard: View {
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var showPermissionAlert = false
    @State private var isCheckingPermissions = false
    @Binding var tempNotificationsEnabled: Bool
    @Binding var tempMode: ReminderMode
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        print("NotificationSettingsCard: Rendering body")
        return VStack(alignment: .leading, spacing: 14) {
            Toggle("Enable Smart Reminders", isOn: $tempNotificationsEnabled)
                .onChange(of: tempNotificationsEnabled) { newValue in
                    print("Toggle changed to: \(newValue)")
                    if newValue {
                        isCheckingPermissions = true
                        UNUserNotificationCenter.current()
                            .getNotificationSettings { settings in
                                DispatchQueue.main.async {
                                    if settings.authorizationStatus
                                        != .authorized
                                    {
                                        showPermissionAlert = true
                                        tempNotificationsEnabled = false
                                        self.onCancel()
                                        print(
                                            "NotificationSettingsCard: onCancel triggered"
                                        )
                                    } else {
                                        self.onSave()
                                        print(
                                            "NotificationSettingsCard: onSave triggered"
                                        )
                                    }
                                    isCheckingPermissions = false
                                }
                            }
                    } else {
                        print("Disabling notifications")
                        self.onSave()
                        print("NotificationSettingsCard: onSave triggered")
                    }
                }
            
//            if tempNotificationsEnabled {
//                HStack(spacing: 16) {
//                    Text("Notification Frequency: ")
//                        .font(.subheadline)
//                    
//                    NotificationModePicker(selectedMode: $tempMode)
//                }
//            }
            
            if isCheckingPermissions {
                ProgressView()
                    .padding(.vertical, 8)
            }

            
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) {
                self.onCancel()
                print("NotificationSettingsCard: onCancel triggered")
            }
            Button("Open Settings") {
                notificationManager.openAppSettings()
            }
        } message: {
            Text(
                "Please enable notifications in Settings to use Smart Reminders."
            )
        }
        .onChange(of: tempMode) { newMode in
            print(
                "NotificationSettingsCard: Mode changed to \(newMode.rawValue)"
            )
            self.onSave()
            print("NotificationSettingsCard: onSave triggered")
        }
    }
}

#Preview {
    NotificationSettingsCard(
        notificationManager: NotificationManager.shared,
        healthKitManager: HealthKitManager(),
        waterIntakeManager: WaterIntakeManager(),
        tempNotificationsEnabled: .constant(false),
        tempMode: .constant(.rare),
        onSave: {},
        onCancel: {}
    )
}
