import SwiftUI
import SwiftData

struct NotificationSettingsCard: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert = false
    @State private var isCheckingPermissions = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Enable Smart Reminders", isOn: $notificationManager.notificationsEnabled)
                .onChange(of: notificationManager.notificationsEnabled) { newValue in
                    if newValue {
                        UNUserNotificationCenter.current().getNotificationSettings { settings in
                            DispatchQueue.main.async {
                                if settings.authorizationStatus != .authorized {
                                    showPermissionAlert = true
                                    notificationManager.notificationsEnabled = false
                                }
                                isCheckingPermissions = false
                            }
                        }
                    }
                }
            if isCheckingPermissions{
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
                                HStack(spacing: 16){
                                    Text("Notification Frequency: ")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Picker("Notification Frequency", selection: $notificationManager.notificationMode) {
                                        Text("Rare").tag(NotificationManager.NotificationMode.rare)
                                        Text("Frequent").tag(NotificationManager.NotificationMode.frequent)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                notificationManager.openAppSettings()
            }
        } message: {
            Text("Please enable notifications in Settings to use Smart Reminders.")
        }
    }
}

#Preview {
    ContentView()
}
