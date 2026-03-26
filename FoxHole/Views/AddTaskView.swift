import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var durationMinutes: Int = 25

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What do you need to do?", text: $name)
                }

                Section("Rough duration") {
                    Picker("Duration", selection: $durationMinutes) {
                        Text("15 min").tag(15)
                        Text("25 min").tag(25)
                        Text("45 min").tag(45)
                        Text("1 hour").tag(60)
                        Text("90 min").tag(90)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = FoxTask(
                            name: name.trimmingCharacters(in: .whitespaces),
                            estimatedDuration: TimeInterval(durationMinutes * 60)
                        )
                        modelContext.insert(task)
                        dismiss()
                    }
                    .disabled(!canAdd)
                }
            }
        }
    }
}
