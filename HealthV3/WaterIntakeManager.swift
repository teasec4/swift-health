import Foundation

class WaterIntakeManager: ObservableObject {
    @Published var waterIntake: Double{
        didSet{
            UserDefaults.standard.set(waterIntake, forKey: "waterIntake")
            UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
        }
    }
    @Published var waterGoal: Double {
            didSet {
                UserDefaults.standard.set(waterGoal, forKey: "waterGoal")
            }
        }
    
    init() {
            // Load waterIntake and waterGoal from UserDefaults
            let savedWaterIntake = UserDefaults.standard.double(forKey: "waterIntake")
            let savedWaterGoal = UserDefaults.standard.double(forKey: "waterGoal") > 0 ? UserDefaults.standard.double(forKey: "waterGoal") : 2000
            let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date()
            
            // Check if the last update was on a different day
            if !Calendar.current.isDateInToday(lastUpdateDate) {
                self.waterIntake = 0
                UserDefaults.standard.set(0, forKey: "waterIntake")
                UserDefaults.standard.set(Date(), forKey: "lastUpdateDate")
            } else {
                self.waterIntake = savedWaterIntake
            }
            
            self.waterGoal = savedWaterGoal
        }
    
    func addWater(amount: Double) {
        waterIntake += amount
    }
    
    func resetWaterIntake() {
        waterIntake = 0
    }
    
    func setWaterGoal(_ goal: Double) {
        waterGoal = goal
    }
}
