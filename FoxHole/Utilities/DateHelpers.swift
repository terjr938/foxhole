import Foundation

enum DateHelpers {
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func startOfTomorrow() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay(for: Date()))!
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
}
