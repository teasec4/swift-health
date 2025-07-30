import Foundation

class WaterIntakeManager: ObservableObject {
    @Published var waterIntake: Double {
        didSet {
            UserDefaults.standard.set(waterIntake, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            let dateKey = dateKey(for: Date())
            waterHistory[dateKey] = waterIntake
            UserDefaults.standard.set(waterHistory, forKey: "waterHistory")
            print("Water intake updated: \(waterIntake)")
        }
    }
    @Published var waterGoal: Double {
        didSet {
            UserDefaults.standard.set(waterGoal, forKey: "waterGoal")
            print("Water goal updated: \(waterGoal)")
        }
    }
    private var waterHistory: [String: Double] = [:]
    
    init() {
        let savedWaterIntake = UserDefaults.standard.double(forKey: "waterIntake")
        let savedWaterGoal = UserDefaults.standard.double(forKey: "waterGoal") > 0 ? UserDefaults.standard.double(forKey: "waterGoal") : 2000
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date.distantPast
        
        if let savedHistory = UserDefaults.standard.dictionary(forKey: "waterHistory") as? [String: Double] {
            self.waterHistory = savedHistory
        }
        
        if !Calendar.current.isDateInToday(lastUpdateDate) {
            print("Resetting waterIntake for new day")
            self.waterIntake = 0
            UserDefaults.standard.set(0, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            NotificationCenter.default.post(name: .dataReset, object: nil)
        } else {
            self.waterIntake = savedWaterIntake
        }
        
        self.waterGoal = savedWaterGoal
        NotificationCenter.default.addObserver(self, selector: #selector(resetIfNewDay), name: .NSCalendarDayChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func resetIfNewDay() {
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastUpdateDate) {
            print("Resetting waterIntake for new day")
            waterIntake = 0
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            NotificationCenter.default.post(name: .dataReset, object: nil)
        }
    }
    
    func addWater(amount: Double) {
        waterIntake += amount
    }
    
    func resetWaterIntake() {
        waterIntake = 0
        print("Water intake reset to 0")
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }
    
    func setWaterGoal(_ goal: Double) {
        waterGoal = goal
    }
    
    func waterIntake(for date: Date) -> Double {
        let dateKey = dateKey(for: date)
        return waterHistory[dateKey] ?? 0
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// Расширение для имени уведомления
extension NSNotification.Name {
    static let dataReset = NSNotification.Name("DataReset")
}
