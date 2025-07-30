import Foundation

class WaterIntakeManager: ObservableObject {
    @Published var waterIntake: Double{
        didSet{
            UserDefaults.standard.set(waterIntake, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            print("Water intake updated: \(waterIntake)")
        }
    }
    @Published var waterGoal: Double {
            didSet {
                UserDefaults.standard.set(waterGoal, forKey: "waterGoal")
                print("Water goal updated: \(waterGoal)")
            }
        }
    
    init() {
            let savedWaterIntake = UserDefaults.standard.double(forKey: "waterIntake")
            let savedWaterGoal = UserDefaults.standard.double(forKey: "waterGoal") > 0 ? UserDefaults.standard.double(forKey: "waterGoal") : 2000
            let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date.distantPast
            
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
            // Подписываемся на смену дня
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
}

// Расширение для имени уведомления
extension NSNotification.Name {
    static let dataReset = NSNotification.Name("DataReset")
}
