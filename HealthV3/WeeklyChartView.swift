import SwiftUI
import Charts

struct WeeklyChartView: View {
    @ObservedObject var waterIntakeManager: WaterIntakeManager
    @State private var weeklyData: [DayData] = []
    
    private struct DayData: Identifiable, Equatable {
        let id = UUID()
        let day: String
        let amount: Double
        
        static func == (lhs: DayData, rhs: DayData) -> Bool {
            lhs.id == rhs.id && lhs.day == rhs.day && lhs.amount == rhs.amount
        }
    }
    
    private func updateWeeklyData() {
        let calendar = Calendar.current
        let now = Date()
        guard let monday = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: now) - 2), to: now) else {
            weeklyData = []
            return
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        
        var data: [DayData] = []
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: monday) else { continue }
            let dayName = formatter.string(from: day).prefix(2).capitalized // Пн, Вт, ...
            let dateKey = dateKey(for: day)
            let amount = waterIntakeManager.waterIntake(for: day)
            data.append(DayData(day: dayName, amount: amount))
        }
        weeklyData = data
        print("WeeklyChartView: Updated weeklyData = \(data.map { "\($0.day): \($0.amount)" })")
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Chart(weeklyData) { data in
                BarMark(
                    x: .value("Day", data.day),
                    y: .value("Water (ml)", data.amount)
                )
            }
            .foregroundStyle(.cyan)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.caption)
                        .foregroundStyle(.black)
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: Decimal.FormatStyle.number.precision(.fractionLength(0)))
                        .font(.caption)
                        .foregroundStyle(.black)
                }
            }
            .chartXAxisLabel(NSLocalizedString("Day", comment: ""))
            .chartYAxisLabel(NSLocalizedString("Water (ml)", comment: ""))
            .frame(height: 200)
            .padding(.horizontal)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: weeklyData)
        }
    
        
        .padding(.horizontal)
        .onAppear {
            updateWeeklyData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .waterIntakeUpdated)) { _ in
            updateWeeklyData()
            print("WeeklyChartView: Updated weeklyData on waterIntakeUpdated")
        }
        .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
            updateWeeklyData()
            print("WeeklyChartView: Updated weeklyData on dataReset")
        }
    }
}

#Preview {
    WeeklyChartView(waterIntakeManager: WaterIntakeManager())
}
