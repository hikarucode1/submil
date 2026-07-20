import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// ウィジェット用スナップショットの読み書き (#26)。
///
/// - アプリ本体: サブスク集計が変わったら `save(_:)` で共有 UserDefaults に書き出し、
///   ウィジェットのタイムラインを再読込する。
/// - ウィジェット拡張: `load()` で最新スナップショットを読む。
/// このファイルは **app / ウィジェット両ターゲット**に含める。
enum WidgetDataStore {
    /// 共有ストアへスナップショットを保存し、ウィジェットを更新する。
    /// App Group entitlement 未設定でも `sharedDefaults` は通常非 nil で、書き込みは
    /// 共有されない領域に落ちる (ウィジェットは `.empty` 表示のまま)。nil ガードは保険。
    static func save(_ snapshot: SubscriptionSnapshot) {
        guard let defaults = WidgetSharedConfig.sharedDefaults else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: WidgetSharedConfig.snapshotKey)
        reloadWidgets()
    }

    /// 共有ストアから最新スナップショットを読む。未保存/失敗時は `.empty`。
    static func load() -> SubscriptionSnapshot {
        guard
            let defaults = WidgetSharedConfig.sharedDefaults,
            let data = defaults.data(forKey: WidgetSharedConfig.snapshotKey),
            let snapshot = try? JSONDecoder().decode(SubscriptionSnapshot.self, from: data)
        else {
            return .empty
        }
        return snapshot
    }

    /// ウィジェットのタイムラインを再読込する。ウィジェット未追加なら実質 no-op。
    static func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetSharedConfig.widgetKind)
        #endif
    }
}
