import SwiftUI

struct EmptyDayView: View {
    @Binding var showBacklog: Bool
    @Binding var showEveningReview: Bool

    var body: some View {
        ContentUnavailableView {
            Label("No tasks for today", systemImage: "pawprint.fill")
        } description: {
            Text("Open your backlog to add tasks, or run the evening review to pick tomorrow's focus.")
        } actions: {
            HStack(spacing: 16) {
                Button("Open Backlog") {
                    showBacklog = true
                }
                .buttonStyle(.borderedProminent)

                Button("Evening Review") {
                    showEveningReview = true
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
