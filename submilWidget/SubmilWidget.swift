import WidgetKit
import SwiftUI

/// タイムラインの 1 エントリ (#26)。
struct SubmilEntry: TimelineEntry {
    let date: Date
    let snapshot: SubscriptionSnapshot
}

/// 共有 UserDefaults のスナップショットを供給する TimelineProvider。
/// 実際の更新はアプリ本体の `WidgetDataStore.save` → `reloadTimelines` で即時に走る。
/// ここでのタイムラインは保険的に数時間後に自動更新する程度。
struct SubmilProvider: TimelineProvider {
    func placeholder(in context: Context) -> SubmilEntry {
        SubmilEntry(
            date: Date(),
            snapshot: SubscriptionSnapshot(monthlyTotalYen: 3980, activeCount: 4, updatedAt: Date())
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SubmilEntry) -> Void) {
        completion(SubmilEntry(date: Date(), snapshot: WidgetDataStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SubmilEntry>) -> Void) {
        let entry = SubmilEntry(date: Date(), snapshot: WidgetDataStore.load())
        let next = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date().addingTimeInterval(6 * 3600)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

/// ホーム画面ウィジェット本体 (#26)。月額合計のみを Small / Medium で表示する。
struct SubmilWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: WidgetSharedConfig.widgetKind, provider: SubmilProvider()) { entry in
            SubmilWidgetView(entry: entry)
        }
        .configurationDisplayName("月額合計")
        .description("登録中サブスクの月額合計を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
