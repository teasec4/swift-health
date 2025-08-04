import Combine
import HealthKit

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var steps: Double = 0
    @Published var calories: Double = 0
    @Published var stepGoal: Double =
        UserDefaults.standard.double(forKey: "stepGoal") > 0
        ? UserDefaults.standard.double(forKey: "stepGoal") : 10000
    private var cancellables = Set<AnyCancellable>()
    private weak var waterIntakeManager: WaterIntakeManager?
    private var isFetchingSteps = false

    init(waterIntakeManager: WaterIntakeManager? = nil) {
        self.waterIntakeManager = waterIntakeManager
        resetIfNewDay()
        Publishers.CombineLatest($steps, $calories)
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] newSteps, newCalories in
                guard let self = self else { return }
                print(
                    "HealthKitManager: Steps or calories updated: steps = \(newSteps), calories = \(newCalories)"
                )
                NotificationCenter.default.post(
                    name: .stepsUpdated,
                    object: nil,
                    userInfo: ["steps": newSteps]
                )
                NotificationManager.shared.scheduleAllNotifications(
                    steps: newSteps,
                    stepGoal: self.stepGoal,
                    water: self.waterIntakeManager?.waterIntake ?? 0.0,
                    waterGoal: self.waterIntakeManager?.waterGoal ?? 2000.0
                )
            }
            .store(in: &cancellables)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetIfNewDay),
            name: .NSCalendarDayChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
        print("HealthKitManager: Initialized with waterIntakeManager = \(String(describing: waterIntakeManager))")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("HealthKitManager: Deinitialized")
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitManager: HealthKit not available on this device")
            return
        }

        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                print("HealthKitManager: Authorization granted")
                self.fetchSteps()
                self.fetchCalories()
                self.startMonitoringStepsAndCalories()
            } else if let error = error {
                print("HealthKitManager: Authorization error: \(error.localizedDescription)")
            }
        }
    }

    func fetchSteps() {
        guard !isFetchingSteps else {
            print("HealthKitManager: Already fetching steps, skipping")
            return
        }
        isFetchingSteps = true
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            print("HealthKitManager: Step count type not available")
            isFetchingSteps = false
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let self = self else { return }
            defer { self.isFetchingSteps = false }
            guard let result = result, let sum = result.sumQuantity() else {
                print("HealthKitManager: Error fetching steps: \(error?.localizedDescription ?? "No data")")
                DispatchQueue.main.async {
                    self.steps = 0.0
                }
                return
            }
            DispatchQueue.main.async {
                self.steps = sum.doubleValue(for: HKUnit.count())
                print("HealthKitManager: Fetched steps: \(self.steps)")
            }
        }
        healthStore.execute(query)
    }

    func fetchSteps(for date: Date, completion: @escaping (Double) -> Void) {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            print("HealthKitManager: Step count type not available")
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("HealthKitManager: Error fetching steps for \(date): \(error?.localizedDescription ?? "No data")")
                completion(0)
                return
            }
            DispatchQueue.main.async {
                let stepCount = sum.doubleValue(for: HKUnit.count())
                print("HealthKitManager: Fetched steps for \(date): \(stepCount)")
                completion(stepCount)
            }
        }
        healthStore.execute(query)
    }

    func fetchCalories() {
        guard let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("HealthKitManager: Calorie type not available")
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("HealthKitManager: Error fetching calories: \(error?.localizedDescription ?? "No data")")
                DispatchQueue.main.async {
                    self?.calories = 0.0
                }
                return
            }
            DispatchQueue.main.async {
                self?.calories = sum.doubleValue(for: HKUnit.kilocalorie())
                print("HealthKitManager: Fetched calories: \(self?.calories ?? 0)")
            }
        }
        healthStore.execute(query)
    }

    func startMonitoringStepsAndCalories() {
        guard
            let stepType = HKObjectType.quantityType(forIdentifier: .stepCount),
            let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        else {
            print("HealthKitManager: Step or calorie type not available")
            return
        }

        let stepsQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] query, completionHandler, error in
            guard let self = self else { return }
            if let error = error {
                print("HealthKitManager: Steps observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            print("HealthKitManager: Steps data updated, fetching new data")
            self.fetchSteps()
            completionHandler()
        }

        let caloriesQuery = HKObserverQuery(sampleType: calorieType, predicate: nil) { [weak self] query, completionHandler, error in
            guard let self = self else { return }
            if let error = error {
                print("HealthKitManager: Calories observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }
            print("HealthKitManager: Calories data updated, fetching new data")
            self.fetchCalories()
            completionHandler()
        }

        healthStore.execute(stepsQuery)
        healthStore.execute(caloriesQuery)

        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if success {
                print("HealthKitManager: Background delivery enabled for steps")
            } else if let error = error {
                print("HealthKitManager: Failed to enable background delivery for steps: \(error.localizedDescription)")
            }
        }

        healthStore.enableBackgroundDelivery(for: calorieType, frequency: .immediate) { success, error in
            if success {
                print("HealthKitManager: Background delivery enabled for calories")
            } else if let error = error {
                print("HealthKitManager: Failed to enable background delivery for calories: \(error.localizedDescription)")
            }
        }
    }

    func setStepGoal(_ goal: Double) {
        stepGoal = max(0, min(goal, 50000))
        UserDefaults.standard.set(stepGoal, forKey: "stepGoal")
        print("HealthKitManager: Step goal set to: \(stepGoal)")
        NotificationManager.shared.scheduleAllNotifications(
            steps: steps,
            stepGoal: stepGoal,
            water: waterIntakeManager?.waterIntake ?? 0.0,
            waterGoal: waterIntakeManager?.waterGoal ?? 2000.0
        )
    }

    @objc func resetIfNewDay() {
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? Date.distantPast
        let now = Date()
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastUpdateDate) {
            print("HealthKitManager: Resetting steps and calories for new day")
            steps = 0.0
            calories = 0.0
            UserDefaults.standard.set(now, forKey: "lastUpdateDate")
            NotificationCenter.default.post(name: .dataReset, object: nil)
        }
    }

    @objc func handleDataReset() {
        print("HealthKitManager: Handling data reset")
        fetchSteps()
        fetchCalories()
    }
}

extension NSNotification.Name {
    static let stepsUpdated = NSNotification.Name("StepsUpdated")
}
