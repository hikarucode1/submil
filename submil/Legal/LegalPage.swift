import Foundation

/// アプリ内で表示する法務ページ (#52, #53)。
/// 実体は `submil-content` リポジトリの GitHub Pages で公開している HTML。
/// アプリ内では `SafariView` (SFSafariViewController) で開く。
enum LegalPage: String, Identifiable, CaseIterable {
    case terms
    case privacy

    var id: String { rawValue }

    /// 設定画面での表示名。
    var title: String {
        switch self {
        case .terms:   return "利用規約"
        case .privacy: return "プライバシーポリシー"
        }
    }

    /// 公開ページの URL。文字列は固定リテラルのため生成は必ず成功する。
    var url: URL {
        switch self {
        case .terms:
            return URL(string: "https://hikarucode1.github.io/submil-content/terms.html")!
        case .privacy:
            return URL(string: "https://hikarucode1.github.io/submil-content/privacy-policy.html")!
        }
    }
}
