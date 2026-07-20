import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Firebase Analytics へのイベント送信を担う (#47)。
///
/// `#if canImport(FirebaseAnalytics)` ガードにより、SPM パッケージ未追加の環境
/// (Linux / CI) では no-op になりビルドが通る。送信箇所は `AnalyticsEvent` を渡すだけ。
enum AnalyticsService {
    /// 主要イベントを送信する。
    static func log(_ event: AnalyticsEvent) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(event.name, parameters: event.parameters)
        #endif
    }
}
