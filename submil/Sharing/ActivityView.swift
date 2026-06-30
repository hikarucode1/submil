import SwiftUI
import UIKit

/// `UIActivityViewController` を SwiftUI から使うためのラッパ (#39)。
/// X / Instagram Story / LINE などへ画像 + テキストを共有する。
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
