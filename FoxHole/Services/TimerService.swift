import Foundation
import SwiftData

@Observable
final class TimerService {
    private(set) var activeTaskID: PersistentIdentifier?
    private(set) var activatedDate: Date?
    private(set) var estimatedDuration: TimeInterval = 0
    private(set) var hasNotifiedOverrun: Bool = false

    var isRunning: Bool { activeTaskID != nil }

    var elapsed: TimeInterval {
        guard let activatedDate else { return 0 }
        return Date().timeIntervalSince(activatedDate)
    }

    var isOverrun: Bool {
        elapsed > estimatedDuration && estimatedDuration > 0
    }

    var progress: Double {
        guard estimatedDuration > 0 else { return 0 }
        return min(elapsed / estimatedDuration, 1.0)
    }

    func start(task: FoxTask) {
        activeTaskID = task.persistentModelID
        activatedDate = task.activatedDate ?? Date()
        estimatedDuration = task.estimatedDuration
        hasNotifiedOverrun = false
        NotificationService.shared.scheduleOverrunNotification(
            at: (task.activatedDate ?? Date()).addingTimeInterval(task.estimatedDuration)
        )
    }

    func stop() {
        activeTaskID = nil
        activatedDate = nil
        hasNotifiedOverrun = false
        NotificationService.shared.cancelOverrunNotification()
    }

    func restore(task: FoxTask) {
        activeTaskID = task.persistentModelID
        activatedDate = task.activatedDate
        estimatedDuration = task.estimatedDuration
        hasNotifiedOverrun = elapsed > estimatedDuration
    }
}
