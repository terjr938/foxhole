import Foundation
import SwiftData

enum TaskStatus: String, Codable, Sendable {
    case backlog
    case scheduled
    case active
    case completed
    case dropped
}

@Model
final class FoxTask {
    var name: String
    var estimatedDuration: TimeInterval
    var timeAnchor: Date?
    var statusRawValue: String
    var scheduledDate: Date?
    var createdDate: Date
    var completedDate: Date?
    var activatedDate: Date?
    var sortOrder: Int

    @Transient
    var status: TaskStatus {
        get { TaskStatus(rawValue: statusRawValue) ?? .backlog }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        name: String,
        estimatedDuration: TimeInterval = 25 * 60,
        timeAnchor: Date? = nil,
        status: TaskStatus = .backlog,
        scheduledDate: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.estimatedDuration = estimatedDuration
        self.timeAnchor = timeAnchor
        self.statusRawValue = status.rawValue
        self.scheduledDate = scheduledDate
        self.createdDate = Date()
        self.completedDate = nil
        self.activatedDate = nil
        self.sortOrder = sortOrder
    }
}
