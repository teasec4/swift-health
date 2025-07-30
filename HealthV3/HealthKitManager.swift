import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var steps: Double = 0
    @Published var calories: Double = 0
    @Published var stepGoal: Double = UserDefaults.standard.double(forKey: "stepGoal") > 0 ? UserDefaults.standard.double(forKey: "stepGoal") : 10000
    private var cancellables = Set<AnyCancellable>()
    private weak var waterIntakeManager: WaterIntakeManager?
    
    init(waterIntakeManager: WaterIntakeManager? = nil) {
        self.waterIntakeManager = waterIntakeManager
        resetIfNewDay()
        // Подписываемся на изменения steps и calories для обновления уведомлений
        Publishers.CombineLatest($steps, $calories)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] newSteps, newCalories in
                guard let self = self else { return }
                print("Steps or calories updated: steps = \(newSteps), calories = \(newCalories)")
                NotificationManager.shared.scheduleAllNotifications(
                    steps: newSteps,
                    stepGoal: self.stepGoal,
                    water: self.waterIntakeManager?.waterIntake ?? 0.0,
                    waterGoal: self.waterIntakeManager?.waterGoal ?? 2000.0
                )
            }
            .store(in: &cancellables)
        
        // Подписываемся на смену дня и сброс данных
        NotificationCenter.default.addObserver(self, selector: #selector(resetIfNewDay), name: .NSCalendarDayChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDataReset), name: .dataReset, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("HealthKit authorization granted")
                self.fetchSteps()
                self.fetchCalories()
                self.startMonitoringStepsAndCalories()
            } else if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchSteps() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching steps: \(error?.localizedDescription ?? "No data")")
                DispatchQueue.main.async {
                    self.steps = 0.0
                }
                return
            }
            DispatchQueue.main.async {
                self.steps = sum.doubleValue(for: HKUnit.count())
                print("Fetched steps: \(self.steps)")
            }
        }
        healthStore.execute(query)
    }
    
    func fetchCalories() {
        guard let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching calories: \(error?.localizedDescription ?? "No data")")
                DispatchQueue.main.async {
                    self.calories = 0.0
                }
                return
            }
            DispatchQueue.main.async {
                self.calories = sum.doubleValue(for: HKUnit.kilocalorie())
                print("Fetched calories: \(self.calories)")
            }
        }
        healthStore.execute(query)
    }
    
    func startMonitoringStepsAndCalories() {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
              let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Step or calorie type is not available")
            return
        }
        
        let stepsQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Steps observer query error: \(error.localizedDescription)")
                return
            }
            
            print("Steps data updated, fetching new data")
            self?.fetchSteps()
            completionHandler()
        }
        
        let caloriesQuery = HKObserverQuery(sampleType: calorieType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("Calories observer query error: \(error.localizedDescription)")
                return
            }
            
            print("Calories data updated, fetching new data")
            self?.fetchCalories()
            completionHandler()
        }
        
        healthStore.execute(stepsQuery)
        healthStore.execute(caloriesQuery)
        
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                print("Background delivery enabled for steps")
            } else if let error = error {
                print("Failed to enable background delivery for steps: \(error.localizedDescription)")
            }
        }
        
        healthStore.enableBackgroundDelivery(for: calorieType, frequency: .immediate) { success, error in
            if success {
                print("Background delivery enabled for calories")
            } else if let error = error {
                print("Failed to enable background delivery for calories: \(error.localizedDescription)")
            }
        }
    }
    
    func setStepGoal(_ goal: Double) {
        stepGoal = goal
        UserDefaults.standard.set(goal, forKey: "stepGoal")
        print("Step goal set to: \(goal)")
    }
    
    @objc func resetIfNewDay() {
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date.distantPast
        let now = Date()
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastUpdateDate) {
            print("Resetting calories for new day")
            calories = 0.0
            UserDefaults.standard.set(now, forKey: "lastUpdateDate")
            NotificationCenter.default.post(name: .dataReset, object: nil)
        }
    }
    
    @objc func handleDataReset() {
        print("HealthKitManager: Handling data reset")
        fetchSteps()
        fetchCalories()
        NotificationManager.shared.scheduleAllNotifications(
            steps: steps,
            stepGoal: stepGoal,
            water: waterIntakeManager?.waterIntake ?? 0.0,
            waterGoal: waterIntakeManager?.waterGoal ?? 2000.0
        )
    }
}
