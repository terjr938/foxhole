import Testing
import Foundation
@testable import FoxHole

// MARK: - FoxTask Tests

struct FoxTaskTests {

    @Test func taskDefaultsToBacklog() {
        let task = FoxTask(name: "Test task")
        #expect(task.status == .backlog)
        #expect(task.scheduledDate == nil)
        #expect(task.estimatedDuration == 25 * 60)
        #expect(task.sortOrder == 0)
    }

    @Test func taskStatusRoundTrips() {
        let task = FoxTask(name: "Test")
        for status in [TaskStatus.backlog, .scheduled, .active, .completed, .dropped] {
            task.status = status
            #expect(task.statusRawValue == status.rawValue)
            #expect(task.status == status)
        }
    }

    @Test func schedulingTaskSetsDate() {
        let task = FoxTask(name: "Test")
        let tomorrow = DateHelpers.startOfTomorrow()
        task.status = .scheduled
        task.scheduledDate = tomorrow
        task.sortOrder = 1
        #expect(task.status == .scheduled)
        #expect(task.scheduledDate == tomorrow)
        #expect(task.sortOrder == 1)
    }

    @Test func completingTaskSetsCompletedDate() {
        let task = FoxTask(name: "Test", status: .active)
        task.status = .completed
        task.completedDate = Date()
        #expect(task.status == .completed)
        #expect(task.completedDate != nil)
    }

    @Test func customDurationIsPreserved() {
        let task = FoxTask(name: "Long task", estimatedDuration: 90 * 60)
        #expect(task.estimatedDuration == 90 * 60)
    }
}

// MARK: - DateHelpers Tests

struct DateHelpersTests {

    @Test func startOfDayIsAtMidnight() {
        let now = Date()
        let start = DateHelpers.startOfDay(for: now)
        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: start)
        #expect(components.hour == 0)
        #expect(components.minute == 0)
        #expect(components.second == 0)
    }

    @Test func sameDayComparisonTrue() {
        let now = Date()
        let later = now.addingTimeInterval(3600)
        #expect(DateHelpers.isSameDay(now, later) == true)
    }

    @Test func differentDayComparisonFalse() {
        let now = Date()
        let twoDaysLater = now.addingTimeInterval(86400 * 2)
        #expect(DateHelpers.isSameDay(now, twoDaysLater) == false)
    }

    @Test func tomorrowIsAfterToday() {
        let today = DateHelpers.startOfDay(for: Date())
        let tomorrow = DateHelpers.startOfTomorrow()
        #expect(tomorrow > today)
    }
}

// MARK: - TimeFormatting Tests

struct TimeFormattingTests {

    @Test func durationFormattingMinutes() {
        #expect(TimeInterval(1500).durationFormatted == "25 min")
        #expect(TimeInterval(900).durationFormatted == "15 min")
    }

    @Test func durationFormattingHours() {
        #expect(TimeInterval(3600).durationFormatted == "1h")
        #expect(TimeInterval(5400).durationFormatted == "1h 30m")
    }

    @Test func timerFormatting() {
        #expect(TimeInterval(754).timerFormatted == "12:34")
        #expect(TimeInterval(60).timerFormatted == "1:00")
        #expect(TimeInterval(5).timerFormatted == "0:05")
    }
}
