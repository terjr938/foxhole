import SwiftUI
import SwiftData

struct ActiveTaskView: View {
    @Bindable var task: FoxTask
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerService.self) private var timerService

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(task.name)
                .font(.title2.weight(.semibold))

            TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    ProgressView(value: min(timerService.elapsed / task.estimatedDuration, 1.0))
                        .tint(timerService.isOverrun ? .orange : .accentColor)

                    HStack {
                        Text(timerService.elapsed.timerFormatted)
                            .monospacedDigit()
                            .font(.title3.weight(.medium))

                        Spacer()

                        Text(task.estimatedDuration.durationFormatted)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if timerService.isOverrun {
                        Text("Over time — no rush, just a heads up")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Button {
                completeTask()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func completeTask() {
        task.status = .completed
        task.completedDate = Date()
        timerService.stop()
    }
}
