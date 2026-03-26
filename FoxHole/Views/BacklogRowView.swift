import SwiftUI

struct BacklogRowView: View {
    let task: FoxTask

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.name)
                .font(.body)

            if task.estimatedDuration > 0 {
                Text(task.estimatedDuration.durationFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
