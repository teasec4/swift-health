import Foundation
import UserNotifications

class ReminderScheduler {
    static func scheduleReminders(
        mode: ReminderMode,
        steps: Double,
        stepGoal: Double,
        water: Double,
        waterGoal: Double
    ) {
        print(
            "Scheduling reminders with mode: \(mode.rawValue), steps: \(steps), stepGoal: \(stepGoal), water: \(water), waterGoal: \(waterGoal)"
        )  // Отладка
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()

        let body = generateBody(
            steps: steps,
            stepGoal: stepGoal,
            water: water,
            waterGoal: waterGoal
        )

        switch mode {
        case .rare:
            NotificationHelper.scheduleNotification(
                id: "rare1",
                title: "💧 Прогресс дня",
                body: body,
                hour: 11,
                minute: 0
            )
            NotificationHelper.scheduleNotification(
                id: "rare2",
                title: "🚶‍♂️ Обновление активности",
                body: body,
                hour: 16,
                minute: 0
            )

        case .frequent:
            NotificationHelper.scheduleNotification(
                id: "freq1",
                title: "💧 Как успехи?",
                body: body,
                hour: 9,
                minute: 0
            )
            NotificationHelper.scheduleNotification(
                id: "freq2",
                title: "🚶‍♂️ Проверь прогресс",
                body: body,
                hour: 11,
                minute: 0
            )
            NotificationHelper.scheduleNotification(
                id: "freq3",
                title: "💧 Ещё немного!",
                body: body,
                hour: 13,
                minute: 0
            )
            NotificationHelper.scheduleNotification(
                id: "freq4",
                title: "🚶‍♂️ Ты справишься",
                body: body,
                hour: 15,
                minute: 0
            )
            NotificationHelper.scheduleNotification(
                id: "freq5",
                title: "💧 Вечерняя проверка",
                body: body,
                hour: 17,
                minute: 0
            )
        }
    }

    private static func generateBody(
        steps: Double,
        stepGoal: Double,
        water: Double,
        waterGoal: Double
    ) -> String {
        let stepsPercent = steps / stepGoal
        let waterPercent = water / waterGoal

        var body = ""

        if stepsPercent < 0.3 {
            body +=
                "Ты прошёл всего \(Int(steps)) шагов. Время немного пройтись. "
        } else if stepsPercent < 0.7 {
            body += "Хороший прогресс — \(Int(steps)) шагов. Продолжай! "
        } else {
            body += "Отлично! Уже \(Int(steps)) шагов. Почти у цели. "
        }

        if waterPercent < 0.3 {
            body += "Не забывай пить воду — всего \(Int(water)) мл. 💧"
        } else if waterPercent < 0.7 {
            body += "Сейчас \(Int(water)) мл воды. Идёшь верным путём. 💪"
        } else {
            body += "Ты почти достиг цели по воде — \(Int(water)) мл. 🔥"
        }

        print("Generated notification body: \(body)")
        return body
    }
}
