import SwiftUI
import SwiftData

struct EveningReviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \FoxTask.sortOrder) private var allTasks: [FoxTask]

    @State private var reviewPhase: ReviewPhase = .closeOut

    enum ReviewPhase {
        case closeOut
        case pickTomorrow
    }

    private var todayTasks: [FoxTask] {
        let startOfToday = DateHelpers.startOfDay(for: Date())
        return allTasks.filter { task in
            let isRelevantStatus = task.status == .scheduled ||
                                   task.status == .active ||
                                   task.status == .completed
            guard isRelevantStatus else { return false }

            if let scheduled = task.scheduledDate {
                return scheduled == startOfToday
            }
            if let completed = task.completedDate, task.status == .completed {
                return DateHelpers.isSameDay(completed, Date())
            }
            return false
        }
    }

    var body: some View {
        NavigationStack {
            reviewContent
                .frame(minWidth: 400, minHeight: 400)
                .navigationTitle(reviewPhase == .closeOut ? "Close Out Today" : "Pick Tomorrow's Focus")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }

    @ViewBuilder
    private var reviewContent: some View {
        switch reviewPhase {
        case .closeOut:
            closeOutContent
        case .pickTomorrow:
            PickTomorrowView {
                dismiss()
            }
        }
    }

    private var closeOutContent: some View {
        VStack(spacing: 0) {
            if todayTasks.isEmpty {
                ContentUnavailableView {
                    Label("Nothing to review", systemImage: "checkmark.circle")
                } description: {
                    Text("No tasks were scheduled for today.")
                }
            } else {
                closeOutList
            }

            Button {
                reviewPhase = .pickTomorrow
            } label: {
                Text("Next: Pick Tomorrow's Focus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }

    private var closeOutList: some View {
        List(todayTasks) { task in
            CloseOutRowView(task: task)
        }
    }
}

struct CloseOutRowView: View {
    @Bindable var task: FoxTask

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.name)
                .font(.headline)

            if task.status == .completed {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                HStack(spacing: 12) {
                    Button("Done") {
                        task.status = .completed
                        task.completedDate = Date()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button("Carry Forward") {
                        task.status = .backlog
                        task.scheduledDate = nil
                        task.sortOrder = 0
                        task.activatedDate = nil
                    }
                    .buttonStyle(.bordered)

                    Button("Drop") {
                        task.status = .dropped
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                }
                .controlSize(.small)
            }
        }
        .padding(.vertical, 4)
    }
}
