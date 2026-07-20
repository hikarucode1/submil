import Foundation

/// ウィジェット表示用の軽量スナップショット (#26)。
///
/// SwiftData ストアを App Group で共有する代わりに、アプリ本体が算出した集計値だけを
/// 共有 UserDefaults に書き出し、ウィジェットはこれを読むだけにする (SwiftData 非依存で単純)。
/// このファイルは **app / ウィジェット両ターゲット**に含める。
struct SubscriptionSnapshot: Codable, Equatable {
    /// アクティブなサブスクの月額換算合計 (円)。
    let monthlyTotalYen: Int
    /// アクティブなサブスク件数。
    let activeCount: Int
    /// 最終更新時刻。
    let updatedAt: Date

    static let empty = SubscriptionSnapshot(monthlyTotalYen: 0, activeCount: 0, updatedAt: .distantPast)
}
