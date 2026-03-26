import UserNotifications

final class NotificationService: @unchecked Sendable {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private enum Identifiers {
        static let eveningReview = "com.foxhole.eveningReview"
        static let rabbitHoleNudge = "com.foxhole.rabbitHoleNudge"
    }

    func requestAuthorization() {
        Task {
            try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        }
    }

    // MARK: - Evening Review

    func scheduleEveningReview(hour: Int, minute: Int) {
        center.removePendingNotificationRequests(
            withIdentifiers: [Identifiers.eveningReview]
        )

        let content = UNMutableNotificationContent()
        content.title = "Time to wrap up"
        content.body = "Take 2 minutes to close out your day and pick tomorrow's focus."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: Identifiers.eveningReview,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    // MARK: - Rabbit Hole Nudge

    func scheduleOverrunNotification(at date: Date) {
        cancelOverrunNotification()

        let timeInterval = date.timeIntervalSinceNow
        guard timeInterval > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Gentle nudge"
        content.body = "Your timer has run over. Just a heads up — no rush."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(timeInterval, 1),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: Identifiers.rabbitHoleNudge,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }

    func cancelOverrunNotification() {
        center.removePendingNotificationRequests(
            withIdentifiers: [Identifiers.rabbitHoleNudge]
        )
    }
}
