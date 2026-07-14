import Foundation

/// アプリのバージョン情報を Info.plist から読む (#57)。
/// `CFBundleShortVersionString` = マーケティングバージョン、`CFBundleVersion` = ビルド番号。
enum AppInfo {
    /// 例: "1.0"。
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    /// 例: "1"。
    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    /// 設定画面に出す表示用文字列。例: "1.0 (build 1)"。
    static var displayVersion: String {
        "\(version) (build \(build))"
    }
}
