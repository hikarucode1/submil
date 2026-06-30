import SwiftUI

/// `ShareCardView` を `UIImage` に焼き込む (#38)。
enum ShareCardRenderer {
    /// 共有用の高解像度画像を生成する。失敗時は nil。
    /// ImageRenderer は SwiftUI のレンダリングを使うためメインアクタ上で呼ぶ。
    @MainActor
    static func image(for content: SavingsShareContent, scale: CGFloat = 3) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(content: content))
        renderer.scale = scale
        return renderer.uiImage
    }
}
