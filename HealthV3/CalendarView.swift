import SwiftUI

struct CalendarView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var selectedDate: Date = Date()
    @State private var steps: Double = 0
    @State private var water: Double = 0

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {
            VStack(spacing: 20) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding(.horizontal)

                HStack(spacing: 20) {
                    ActivityRingView(
                        progress: steps / healthKitManager.stepGoal,
                        color: .red
                    )
                    .frame(width: 100, height: 100)

                    ActivityRingView(
                        progress: water / waterIntakeManager.waterGoal,
                        color: .cyan
                    )
                    .frame(width: 100, height: 100)
                }
                .padding()

                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.red)
                            Text(NSLocalizedString("Steps", comment: ""))
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        Text(
                            String(
                                format: NSLocalizedString("%d", comment: ""),
                                Int(steps)

                            )

                        )
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.leading, 24)
                        .fixedSize()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: 160)

                    //                    Spacer()

                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.cyan)
                            Text(NSLocalizedString("Water", comment: ""))
                                .font(.headline)
                                .foregroundColor(.cyan)
                        }
                        Text(
                            String(
                                format: NSLocalizedString(
                                    "%d",
                                    comment: ""
                                ),
                                Int(water),
                            )
                        )
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.leading, 24)
                        .fixedSize()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.cyan.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .frame(width: 160)
                }
                .padding(.horizontal)
                .frame(width: 160)
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                }
            }

            .onChange(of: selectedDate) { newDate in
                updateData(for: newDate)
            }
            .onAppear {
                updateData(for: selectedDate)
            }
        }
    }

    private func updateData(for date: Date) {
        healthKitManager.fetchSteps(for: date) { steps in
            self.steps = steps
            print("CalendarView: Fetched steps for \(date): \(steps)")
        }
        water = waterIntakeManager.waterIntake(for: date)
        print("CalendarView: Fetched water for \(date): \(water)")
    }
}

struct ActivityRingView: View {
    let progress: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(color)
                .shadow(radius: 2)

            Circle()
                .trim(from: 0, to: min(progress, 1))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(color)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
                .shadow(radius: 2)

            Text(String(format: "%.0f%%", min(progress, 1) * 100))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
    }
}

#Preview {
    CalendarView(
        healthKitManager: HealthKitManager(
            waterIntakeManager: WaterIntakeManager()
        ),
        waterIntakeManager: WaterIntakeManager()
    )
}
