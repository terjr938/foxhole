import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var settings: [UserSettings]
    @Environment(\.modelContext) private var modelContext

    private var currentSettings: UserSettings? {
        settings.first
    }

    @State private var reviewTime: Date = {
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("Evening Review") {
                    DatePicker(
                        "Review time",
                        selection: $reviewTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }
            .frame(minWidth: 350, minHeight: 200)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let s = currentSettings {
                    var components = DateComponents()
                    components.hour = s.eveningReviewHour
                    components.minute = s.eveningReviewMinute
                    reviewTime = Calendar.current.date(from: components) ?? reviewTime
                }
            }
        }
    }

    private func saveSettings() {
        let components = Calendar.current.dateComponents([.hour, .minute], from: reviewTime)
        let hour = components.hour ?? 20
        let minute = components.minute ?? 0

        if let s = currentSettings {
            s.eveningReviewHour = hour
            s.eveningReviewMinute = minute
        } else {
            let s = UserSettings(eveningReviewHour: hour, eveningReviewMinute: minute)
            modelContext.insert(s)
        }

        NotificationService.shared.scheduleEveningReview(hour: hour, minute: minute)
    }
}
