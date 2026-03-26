import Foundation

extension TimeInterval {
    /// Formats a duration for display: "25 min", "1h 10m", "2h"
    var durationFormatted: String {
        let minutes = Int(self) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours == 0 {
            return "\(minutes) min"
        } else if remainingMinutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(remainingMinutes)m"
        }
    }

    /// Formats elapsed time as "12:34" for timer display
    var timerFormatted: String {
        let totalSeconds = Int(self)
        let m = totalSeconds / 60
        let s = totalSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
