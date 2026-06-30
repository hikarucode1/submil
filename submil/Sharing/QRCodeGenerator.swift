import CoreImage.CIFilterBuiltins
import UIKit

/// 文字列から QR コード画像を生成するヘルパ (#38)。
enum QRCodeGenerator {
    private static let context = CIContext()

    /// `string` をエンコードした QR コードを一辺 `size` pt の `UIImage` として返す。
    /// 生成に失敗した場合は nil。
    static func image(from string: String, size: CGFloat = 160) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        guard let data = string.data(using: .utf8) else { return nil }
        filter.message = data
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }

        // CIFilter の出力は小さい (1 モジュール = 1px) ので目標サイズへ拡大する。
        let scale = size / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
