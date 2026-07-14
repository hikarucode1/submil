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

    /// 公開ページのファイル名。
    private var fileName: String {
        switch self {
        case .terms:   return "terms.html"
        case .privacy: return "privacy-policy.html"
        }
    }

    /// 公開ページの URL。配信ドメインは `ContentCache.defaultBaseURL` と共有し、
    /// ドメイン変更時のドリフトを防ぐ。
    var url: URL {
        ContentCache.defaultBaseURL.appendingPathComponent(fileName)
    }
}
