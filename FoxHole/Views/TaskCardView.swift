import SwiftUI
import SwiftData

struct TaskCardView: View {
    @Bindable var task: FoxTask
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerService.self) private var timerService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let anchor = task.timeAnchor {
                Text(anchor, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(task.name)
                .font(.headline)

            HStack {
                Label(task.estimatedDuration.durationFormatted, systemImage: "clock")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    startTask()
                } label: {
                    Text("Start This Now")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.borderedProminent)
                .disabled(timerService.isRunning)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func startTask() {
        task.status = .active
        task.activatedDate = Date()
        timerService.start(task: task)
    }
}
