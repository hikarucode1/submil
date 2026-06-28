import Foundation

/// アプリ外部リンクの集約。配信前のため URL は暫定値。
/// App Store ID 確定後 (#54 App Store Connect 設定) に `appStoreURL` を差し替える。
enum AppLink {
    /// App Store のアプリページ。シェアカードの QR / シェアテキストで使う。
    /// TODO(#54): 実際の App Store ID に差し替える。
    static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/submil")!
}
