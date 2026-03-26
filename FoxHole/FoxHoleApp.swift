import SwiftUI
import SwiftData

@main
struct FoxHoleApp: App {
    let sharedModelContainer: ModelContainer
    @State private var timerService = TimerService()

    init() {
        let schema = Schema([
            FoxTask.self,
            UserSettings.self,
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            DailyFocusView()
                .environment(timerService)
                .onAppear {
                    NotificationService.shared.requestAuthorization()
                    ensureSettingsExist()
                    cleanUpStaleTasks()
                    restoreActiveTask()
                }
        }
        .modelContainer(sharedModelContainer)

        #if os(macOS)
        MenuBarExtra {
            MenuBarView()
                .environment(timerService)
                .modelContainer(sharedModelContainer)
        } label: {
            if timerService.isRunning {
                Label(timerService.elapsed.timerFormatted, systemImage: "timer")
            } else {
                Label("FoxHole", systemImage: "pawprint.fill")
            }
        }
        .menuBarExtraStyle(.window)
        #endif
    }

    private func ensureSettingsExist() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<UserSettings>()
        let existing = (try? context.fetch(descriptor)) ?? []
        if existing.isEmpty {
            let settings = UserSettings()
            context.insert(settings)
            NotificationService.shared.scheduleEveningReview(
                hour: settings.eveningReviewHour,
                minute: settings.eveningReviewMinute
            )
        } else if let settings = existing.first {
            NotificationService.shared.scheduleEveningReview(
                hour: settings.eveningReviewHour,
                minute: settings.eveningReviewMinute
            )
        }
    }

    /// Move tasks from previous days that are still scheduled (not completed)
    /// back to the backlog so they don't clutter future days.
    private func cleanUpStaleTasks() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<FoxTask>(
            predicate: #Predicate { $0.statusRawValue == "scheduled" }
        )
        guard let staleTasks = try? context.fetch(descriptor) else { return }
        let startOfToday = DateHelpers.startOfDay(for: Date())
        for task in staleTasks {
            guard let scheduled = task.scheduledDate, scheduled < startOfToday else { continue }
            task.status = .backlog
            task.scheduledDate = nil
            task.sortOrder = 0
        }
    }

    private func restoreActiveTask() {
        let context = sharedModelContainer.mainContext
        var descriptor = FetchDescriptor<FoxTask>(
            predicate: #Predicate { $0.statusRawValue == "active" }
        )
        descriptor.fetchLimit = 1
        if let activeTask = try? context.fetch(descriptor).first {
            timerService.restore(task: activeTask)
        }
    }
}
