import SwiftUI

struct NotificationSettingsCard: View {
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var showPermissionAlert = false
    @State private var isCheckingPermissions = false
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        print("NotificationSettingsCard: Rendering body")
        return VStack(alignment: .leading) {
            Toggle("Enable Smart Reminders", isOn: $notificationManager.notificationsEnabled)
                .onChange(of: notificationManager.notificationsEnabled) { newValue in
                    print("Toggle changed to: \(newValue)")
                    if newValue {
                        isCheckingPermissions = true
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            DispatchQueue.main.async {
                                if settings.authorizationStatus != .authorized {
                                    showPermissionAlert = true
                                    notificationManager.notificationsEnabled = false
                                    self.onCancel()
                                    print("NotificationSettingsCard: onCancel triggered")
                                } else {
                                    notificationManager.scheduleAllNotifications(
                                        steps: healthKitManager.steps,
                                        stepGoal: healthKitManager.stepGoal,
                                        water: waterIntakeManager.waterIntake,
                                        waterGoal: waterIntakeManager.waterGoal
                                    )
                                    self.onSave()
                                    print("NotificationSettingsCard: onSave triggered")
                                }
                                isCheckingPermissions = false
                            }
                        }
                    } else {
                        print("Disabling notifications")
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        self.onSave()
                        print("NotificationSettingsCard: onSave triggered")
                    }
                }
            if isCheckingPermissions {
                ProgressView()
                    .padding(.vertical, 8)
            }

            Divider()

            Button {
                print("Button tapped: Attempting to open system settings")
                notificationManager.openAppSettings()
            } label: {
                Label("Open System Settings", systemImage: "gear")
            }
            .foregroundColor(.blue)
            
            if notificationManager.notificationsEnabled {
                HStack(spacing: 16) {
                    Text("Notification Frequency: ")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    NotificationModePicker(selectedMode: $notificationManager.mode)
                }
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
            Text("Please enable notifications in Settings to use Smart Reminders.")
        }
        .onChange(of: notificationManager.mode) { newMode in
            print("NotificationSettingsCard: Mode changed to \(newMode.rawValue)")
            notificationManager.scheduleAllNotifications(
                steps: healthKitManager.steps,
                stepGoal: healthKitManager.stepGoal,
                water: waterIntakeManager.waterIntake,
                waterGoal: waterIntakeManager.waterGoal
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
        onSave: {},
        onCancel: {}
    )
}
