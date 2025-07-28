import SwiftUI
import SwiftData

struct NotificationSettingsCard: View {
    @ObservedObject var notificationManager = NotificationManager.shared
    @State private var showPermissionAlert = false

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
                            }
                        }
                    }
                }

            Divider()

            Button {
                notificationManager.openAppSettings()
                } label: {
                Label("Open System Settings", systemImage: "gear")
            }
                
            
            .foregroundColor(.blue)
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
