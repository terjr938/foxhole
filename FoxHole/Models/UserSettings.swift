import Foundation
import SwiftData

@Model
final class UserSettings {
    var eveningReviewHour: Int
    var eveningReviewMinute: Int

    init(eveningReviewHour: Int = 20, eveningReviewMinute: Int = 0) {
        self.eveningReviewHour = eveningReviewHour
        self.eveningReviewMinute = eveningReviewMinute
    }
}
