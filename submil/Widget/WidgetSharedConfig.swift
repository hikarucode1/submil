import Foundation

/// アプリ本体とウィジェット拡張で共有する定数 (#26)。
///
/// - このファイルは **app ターゲットとウィジェットターゲットの両方**に含める
///   (Xcode の Target Membership で両方にチェック)。詳細は `docs/setup/widget.md`。
/// - `appGroupID` は Developer Portal で作成し、両ターゲットの App Groups 権限に追加した値と一致させる。
enum WidgetSharedConfig {
    /// App Group ID。両ターゲットの entitlements と一致させること。
    static let appGroupID = "group.com.hikaru.failuremuseum.submil"

    /// 共有 UserDefaults 内でスナップショットを格納するキー。
    static let snapshotKey = "widget.subscriptionSnapshot"

    /// ウィジェットの kind 識別子 (WidgetKit の reload / 定義で使う)。
    static let widgetKind = "SubmilMonthlyTotalWidget"

    /// 共有 UserDefaults。App Group 未設定の環境では nil になり得るため呼び出し側で握る。
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
}
