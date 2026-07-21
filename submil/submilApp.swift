import SwiftUI
import SwiftData

@main
struct submilApp: App {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Subscription.self,
            UsageEvaluation.self,
            CancellationLog.self,
        ])
        // スクリーンショット撮影 (#50) 時は永続化せず毎回クリーンな状態から始める。
        var storedInMemoryOnly = false
        #if DEBUG
        storedInMemoryOnly = SnapshotSupport.isActive
        #endif
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: storedInMemoryOnly)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}
