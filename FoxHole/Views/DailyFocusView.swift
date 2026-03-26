import SwiftUI
import SwiftData

struct DailyFocusView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerService.self) private var timerService

    @Query(
        filter: #Predicate<FoxTask> { task in
            task.statusRawValue == "scheduled" || task.statusRawValue == "active"
        },
        sort: \FoxTask.sortOrder
    ) private var scheduledTasks: [FoxTask]

    @State private var showBacklog = false
    @State private var showCompletedHistory = false
    @State private var showEveningReview = false
    @State private var showSettings = false

    private var todayTasks: [FoxTask] {
        let startOfToday = DateHelpers.startOfDay(for: Date())
        return scheduledTasks.filter { task in
            guard let scheduled = task.scheduledDate else { return false }
            return scheduled == startOfToday
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if todayTasks.isEmpty {
                    EmptyDayView(showBacklog: $showBacklog, showEveningReview: $showEveningReview)
                } else {
                    timelineContent
                }
            }
            .navigationTitle(Text(Date(), format: .dateTime.weekday(.wide).month(.wide).day()))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showBacklog = true
                    } label: {
                        Label("Backlog", systemImage: "tray.full")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCompletedHistory = true
                    } label: {
                        Label("Completed", systemImage: "checkmark.circle")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !todayTasks.isEmpty {
                    Button {
                        showEveningReview = true
                    } label: {
                        Text("Evening Review")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
            }
            .sheet(isPresented: $showBacklog) {
                BacklogView()
            }
            .sheet(isPresented: $showCompletedHistory) {
                CompletedHistoryView()
            }
            .sheet(isPresented: $showEveningReview) {
                EveningReviewView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    private var timelineContent: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(todayTasks.enumerated()), id: \.element.persistentModelID) { index, task in
                    timelineEntry(for: task, isLast: index == todayTasks.count - 1)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func timelineEntry(for task: FoxTask, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Timeline rail
            VStack(spacing: 0) {
                Circle()
                    .fill(dotColor(for: task))
                    .frame(width: 12, height: 12)
                    .padding(.top, 8)

                if !isLast {
                    Rectangle()
                        .fill(.quaternary)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Task content
            VStack(alignment: .leading, spacing: 4) {
                if let anchor = task.timeAnchor {
                    Text(anchor, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if task.status == .active {
                    ActiveTaskView(task: task)
                } else {
                    TaskCardView(task: task)
                }
            }
            .padding(.bottom, isLast ? 0 : 16)
        }
    }

    private func dotColor(for task: FoxTask) -> Color {
        switch task.status {
        case .active:
            return .accentColor
        case .completed:
            return .green
        default:
            return .secondary
        }
    }
}

#Preview {
    DailyFocusView()
        .modelContainer(for: [FoxTask.self, UserSettings.self], inMemory: true)
        .environment(TimerService())
}
