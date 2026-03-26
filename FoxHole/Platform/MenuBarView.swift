#if os(macOS)
import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(TimerService.self) private var timerService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let taskID = timerService.activeTaskID,
               let task = modelContext.registeredModel(for: taskID) as FoxTask? {
                Text(task.name)
                    .font(.headline)

                TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                    HStack {
                        Text(timerService.elapsed.timerFormatted)
                            .monospacedDigit()
                        Text("/ \(task.estimatedDuration.durationFormatted)")
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }

                Divider()

                Button("Mark Done") {
                    task.status = .completed
                    task.completedDate = Date()
                    timerService.stop()
                }
            } else {
                Text("No active task")
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button("Quit FoxHole") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(minWidth: 200)
    }
}
#endif
