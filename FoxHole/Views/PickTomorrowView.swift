import SwiftUI
import SwiftData

struct PickTomorrowView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<FoxTask> { $0.statusRawValue == "backlog" },
        sort: \FoxTask.createdDate,
        order: .reverse
    ) private var backlogTasks: [FoxTask]

    @State private var selectedIDs: Set<PersistentIdentifier> = []

    var onComplete: () -> Void

    private var canConfirm: Bool {
        !selectedIDs.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            if backlogTasks.isEmpty {
                ContentUnavailableView {
                    Label("Backlog is empty", systemImage: "tray")
                } description: {
                    Text("Add tasks to your backlog first, then come back to pick tomorrow's focus.")
                }
            } else {
                taskSelectionList
            }

            Button {
                scheduleTomorrow()
            } label: {
                Text("Confirm (\(selectedIDs.count) of 3)")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canConfirm)
            .padding()
        }
    }

    private var taskSelectionList: some View {
        List {
            Section {
                Text("Pick up to 3 tasks for tomorrow")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                taskRows
            }
        }
    }

    @ViewBuilder
    private var taskRows: some View {
        ForEach(backlogTasks) { task in
            taskRow(for: task)
        }
    }

    private func taskRow(for task: FoxTask) -> some View {
        let isSelected = selectedIDs.contains(task.persistentModelID)
        return Button {
            toggleSelection(task)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.name)
                        .font(.body)
                    if task.estimatedDuration > 0 {
                        Text(task.estimatedDuration.durationFormatted)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(.primary)
    }

    private func toggleSelection(_ task: FoxTask) {
        let id = task.persistentModelID
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else if selectedIDs.count < 3 {
            selectedIDs.insert(id)
        }
    }

    private func scheduleTomorrow() {
        let tomorrow = DateHelpers.startOfTomorrow()
        var order = 0
        for task in backlogTasks where selectedIDs.contains(task.persistentModelID) {
            task.status = .scheduled
            task.scheduledDate = tomorrow
            task.sortOrder = order
            order += 1
        }
        onComplete()
    }
}
