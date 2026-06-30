import SafariServices
import SwiftUI

/// アフィリンクをアプリ内ブラウザで開くための SFSafariViewController ラッパ (#43)。
/// Apple 推奨のアプリ内ブラウザ。外部 Safari に飛ばさず復帰しやすい。
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}
