import SwiftUI
import SwiftData

struct CompletedHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(
        filter: #Predicate<FoxTask> { $0.statusRawValue == "completed" },
        sort: \FoxTask.completedDate,
        order: .reverse
    ) private var completedTasks: [FoxTask]

    @State private var isSelecting = false
    @State private var selection = Set<PersistentIdentifier>()

    var body: some View {
        NavigationStack {
            Group {
                if completedTasks.isEmpty {
                    emptyState
                } else {
                    taskList
                }
            }
            .frame(minWidth: 400, minHeight: 400)
            .navigationTitle("Completed")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !completedTasks.isEmpty {
                        Button(isSelecting ? "Done Editing" : "Select") {
                            withAnimation {
                                isSelecting.toggle()
                                if !isSelecting {
                                    selection.removeAll()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                Text("No completed tasks yet")
                    .font(.headline)
                Text("Tasks you finish will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var taskList: some View {
        VStack(spacing: 0) {
            List {
                ForEach(completedTasks) { task in
                    completedRow(for: task)
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(completedTasks[index])
                    }
                }
            }

            if isSelecting && !selection.isEmpty {
                purgeBar
            }
        }
    }

    @ViewBuilder
    private func completedRow(for task: FoxTask) -> some View {
        HStack {
            if isSelecting {
                Image(systemName: selection.contains(task.persistentModelID)
                      ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selection.contains(task.persistentModelID)
                                    ? .blue : .secondary)
                    .onTapGesture {
                        toggleSelection(task)
                    }
            }

            CompletedRowView(task: task)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelecting {
                toggleSelection(task)
            }
        }
    }

    private func toggleSelection(_ task: FoxTask) {
        let id = task.persistentModelID
        if selection.contains(id) {
            selection.remove(id)
        } else {
            selection.insert(id)
        }
    }

    private var purgeBar: some View {
        HStack {
            Text("\(selection.count) selected")
                .foregroundStyle(.secondary)

            Spacer()

            Button(role: .destructive) {
                purgeSelected()
            } label: {
                Label("Purge", systemImage: "trash")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .background(.bar)
    }

    private func purgeSelected() {
        for task in completedTasks where selection.contains(task.persistentModelID) {
            modelContext.delete(task)
        }
        selection.removeAll()
        if completedTasks.isEmpty {
            isSelecting = false
        }
    }
}

struct CompletedRowView: View {
    let task: FoxTask

    private var actualDuration: TimeInterval? {
        guard let started = task.activatedDate, let finished = task.completedDate else {
            return nil
        }
        return finished.timeIntervalSince(started)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.name)
                .font(.body)

            HStack(spacing: 12) {
                if let completed = task.completedDate {
                    Label(completed.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "checkmark.circle")
                }

                if let started = task.activatedDate {
                    Label(started.formatted(.dateTime.hour().minute()), systemImage: "play.circle")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                if let actual = actualDuration {
                    Label("Actual: \(actual.durationFormatted)", systemImage: "timer")
                }

                Label("Est: \(task.estimatedDuration.durationFormatted)", systemImage: "hourglass")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
