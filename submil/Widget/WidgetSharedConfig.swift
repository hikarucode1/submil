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

    /// 共有 UserDefaults。
    ///
    /// 注意: `UserDefaults(suiteName:)` は App Group entitlement が未設定でも **非 nil を返す**
    /// (書き込みは共有されない領域に落ち、コンソールに CFPrefs 警告が出るだけ)。
    /// nil になるのは suiteName が bundle id と同一など不正な場合のみで、このガードは保険。
    /// entitlement 未設定時はウィジェット側から読めず `.empty` 表示になる (`docs/setup/widget.md`)。
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
}
