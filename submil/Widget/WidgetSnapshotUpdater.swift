import Foundation

/// アクティブなサブスクからウィジェット用スナップショットを作って保存する (#26)。
///
/// `Subscription` (@Model) に依存するため **app ターゲット専用** (ウィジェットターゲットには含めない)。
/// 集計ロジックは HomeView の月額合計 (`monthlyEquivalent` の総和) と一致させる。
enum WidgetSnapshotUpdater {
    static func update(from subscriptions: [Subscription]) {
        let active = subscriptions.filter(\.isActive)
        let snapshot = SubscriptionSnapshot(
            monthlyTotalYen: active.reduce(0) { $0 + $1.monthlyEquivalent },
            activeCount: active.count,
            updatedAt: .now
        )
        WidgetDataStore.save(snapshot)
    }
}
