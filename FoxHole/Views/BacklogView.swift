import SwiftUI
import SwiftData

struct BacklogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(
        filter: #Predicate<FoxTask> { $0.statusRawValue == "backlog" },
        sort: \FoxTask.createdDate,
        order: .reverse
    ) private var backlogTasks: [FoxTask]

    @Query(
        filter: #Predicate<FoxTask> { task in
            task.statusRawValue == "scheduled" || task.statusRawValue == "active"
        },
        sort: \FoxTask.sortOrder
    ) private var scheduledTasks: [FoxTask]

    private var todayTaskCount: Int {
        let startOfToday = DateHelpers.startOfDay(for: Date())
        return scheduledTasks.filter { $0.scheduledDate == startOfToday }.count
    }

    private var canAddToToday: Bool {
        todayTaskCount < 3
    }

    @State private var showAddTask = false
    @State private var newTaskName = ""
    @State private var newTaskDuration: Int = 25
    @State private var editingTask: FoxTask?
    @State private var editName = ""
    @State private var editDuration: Int = 25

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showAddTask {
                    addTaskForm
                        .padding()
                    Divider()
                }

                if backlogTasks.isEmpty && !showAddTask {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Backlog is empty")
                            .font(.headline)
                        Text("Tap + to add your first task.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else if !backlogTasks.isEmpty {
                    List {
                        ForEach(backlogTasks) { task in
                            if editingTask?.persistentModelID == task.persistentModelID {
                                editTaskForm
                            } else {
                                BacklogRowView(task: task)
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            editName = task.name
                                            editDuration = Int(task.estimatedDuration / 60)
                                            editingTask = task
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                modelContext.delete(backlogTasks[index])
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 400, minHeight: 400)
            .navigationTitle("Backlog")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Task", systemImage: "plus") {
                        showAddTask = true
                    }
                    .disabled(showAddTask)
                }
            }
        }
    }

    private var addTaskForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("New Task")
                .font(.headline)

            TextField("What do you need to do?", text: $newTaskName)
                .textFieldStyle(.roundedBorder)

            Picker("Duration", selection: $newTaskDuration) {
                Text("15 min").tag(15)
                Text("25 min").tag(25)
                Text("45 min").tag(45)
                Text("1 hour").tag(60)
                Text("90 min").tag(90)
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Cancel") {
                    showAddTask = false
                    newTaskName = ""
                    newTaskDuration = 25
                }

                Spacer()

                Button("Add to Today") {
                    addTask(scheduleForToday: true)
                }
                .disabled(newTaskName.trimmingCharacters(in: .whitespaces).isEmpty || !canAddToToday)

                Button("Add") {
                    addTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newTaskName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private var editTaskForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Task name", text: $editName)
                .textFieldStyle(.roundedBorder)

            Picker("Duration", selection: $editDuration) {
                Text("15 min").tag(15)
                Text("25 min").tag(25)
                Text("45 min").tag(45)
                Text("1 hour").tag(60)
                Text("90 min").tag(90)
            }
            .pickerStyle(.segmented)

            HStack {
                Button("Cancel") {
                    editingTask = nil
                }

                Spacer()

                Button("Save to Today") {
                    saveEdit(scheduleForToday: true)
                }
                .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty || !canAddToToday)

                Button("Save") {
                    saveEdit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(.vertical, 4)
    }

    private func saveEdit(scheduleForToday: Bool = false) {
        let trimmed = editName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let task = editingTask else { return }
        task.name = trimmed
        task.estimatedDuration = TimeInterval(editDuration * 60)
        if scheduleForToday {
            scheduleTask(task)
        }
        editingTask = nil
    }

    private func addTask(scheduleForToday: Bool = false) {
        let trimmed = newTaskName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let task = FoxTask(
            name: trimmed,
            estimatedDuration: TimeInterval(newTaskDuration * 60)
        )
        modelContext.insert(task)

        if scheduleForToday {
            scheduleTask(task)
        }

        showAddTask = false
        newTaskName = ""
        newTaskDuration = 25
    }

    private func scheduleTask(_ task: FoxTask) {
        task.status = .scheduled
        task.scheduledDate = DateHelpers.startOfDay(for: Date())
        task.sortOrder = todayTaskCount
    }
}
