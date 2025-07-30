import Foundation

class WaterIntakeManager: ObservableObject {
    @Published var waterIntake: Double {
        didSet {
            let newIntake = max(0, min(waterIntake, 10000)) // Ограничение: 0...10000 мл
            if newIntake != waterIntake {
                waterIntake = newIntake
            }
            let date = Date()
            let dateKey = dateKey(for: date)
            UserDefaults.standard.set(newIntake, forKey: "waterIntake")
            UserDefaults.standard.set(date, forKey: "lastUpdateDate")
            waterHistory[dateKey] = newIntake
            UserDefaults.standard.set(waterHistory, forKey: "waterHistory")
            print("WaterIntakeManager: Updated intake to \(newIntake) ml (from \(oldValue))")
        }
    }
    @Published var waterGoal: Double {
        didSet {
            let newGoal = max(0, min(waterGoal, 10000)) // Ограничение: 0...10000 мл
            if newGoal != waterGoal {
                waterGoal = newGoal
            }
            UserDefaults.standard.set(newGoal, forKey: "waterGoal")
            print("WaterIntakeManager: Updated goal to \(newGoal) ml (from \(oldValue))")
        }
    }
    private var waterHistory: [String: Double] = [:]

    init() {
        // Загрузка данных
        let savedWaterIntake = UserDefaults.standard.double(forKey: "waterIntake")
        let savedWaterGoal = UserDefaults.standard.double(forKey: "waterGoal")
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date
            ?? Date.distantPast
        let savedHistory = UserDefaults.standard.dictionary(forKey: "waterHistory") as? [String: Double] ?? [:]

        // Проверка и очистка некорректных данных
        let isValidIntake = savedWaterIntake >= 0 && savedWaterIntake <= 10000
        let isValidGoal = savedWaterGoal >= 0 && savedWaterGoal <= 10000
        let isValidHistory = savedHistory.allSatisfy { $0.value >= 0 && $0.value <= 10000 }

        if !isValidIntake || !isValidGoal || !isValidHistory {
            print("WaterIntakeManager: Detected invalid data. Resetting UserDefaults.")
            UserDefaults.standard.set(0, forKey: "waterIntake")
            UserDefaults.standard.set(2000, forKey: "waterGoal")
            UserDefaults.standard.set([:], forKey: "waterHistory")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            self.waterIntake = 0
            self.waterGoal = 2000
            self.waterHistory = [:]
        } else {
            self.waterGoal = savedWaterGoal > 0 ? savedWaterGoal : 2000
            self.waterIntake = Calendar.current.isDateInToday(lastUpdateDate) ? savedWaterIntake : 0
            self.waterHistory = savedHistory
        }

        print("WaterIntakeManager: Initialized with waterIntake = \(waterIntake), waterGoal = \(waterGoal), history = \(waterHistory)")

        if !Calendar.current.isDateInToday(lastUpdateDate) {
            print("WaterIntakeManager: Resetting waterIntake for new day")
            let dateKey = dateKey(for: Date())
            waterHistory[dateKey] = 0
            UserDefaults.standard.set(waterHistory, forKey: "waterHistory")
            UserDefaults.standard.set(0, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            self.waterIntake = 0
            NotificationCenter.default.post(name: .dataReset, object: nil)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetIfNewDay),
            name: .NSCalendarDayChanged,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func resetIfNewDay() {
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date
            ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastUpdateDate) {
            print("WaterIntakeManager: Resetting waterIntake for new day")
            let dateKey = dateKey(for: Date())
            waterHistory[dateKey] = 0
            UserDefaults.standard.set(waterHistory, forKey: "waterHistory")
            UserDefaults.standard.set(0, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            waterIntake = 0
            NotificationCenter.default.post(name: .dataReset, object: nil)
        }
    }

    func addWater(amount: Double) {
        let cappedAmount = max(-10000, min(amount, 10000)) // Ограничение: ±10000 мл
        waterIntake += cappedAmount
        print("WaterIntakeManager: Changed intake by \(cappedAmount > 0 ? "+" : "")\(cappedAmount) ml")
    }

    func resetWaterIntake() {
        waterIntake = 0
        let dateKey = dateKey(for: Date())
        waterHistory[dateKey] = 0
        UserDefaults.standard.set(waterHistory, forKey: "waterHistory")
        print("WaterIntakeManager: Water intake reset to 0")
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    func setWaterGoal(_ goal: Double) {
        waterGoal = max(0, min(goal, 10000)) // Ограничение: 0...10000 мл
        print("WaterIntakeManager: Set water goal to \(goal) ml")
    }

    func waterIntake(for date: Date) -> Double {
        let dateKey = dateKey(for: date)
        let intake = waterHistory[dateKey] ?? 0
        print("WaterIntakeManager: Fetched intake for \(dateKey): \(intake) ml")
        return intake
    }

    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }
}

// Расширение для имени уведомления
extension NSNotification.Name {
    static let dataReset = NSNotification.Name("DataReset")
}
