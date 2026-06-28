import Foundation
import Testing
import UIKit
@testable import submil

@Suite struct QRCodeGeneratorTests {
    @Test func generatesImageForValidString() {
        let image = QRCodeGenerator.image(from: "https://example.com", size: 120)
        #expect(image != nil)
    }

    @Test func respectsRequestedSize() {
        let size: CGFloat = 200
        let image = QRCodeGenerator.image(from: "https://example.com", size: size)
        // CIFilter の整数モジュール数による丸めで誤差が出るため許容幅で確認する。
        #expect(image != nil)
        if let image {
            #expect(abs(image.size.width - size) <= 4)
            #expect(abs(image.size.height - size) <= 4)
        }
    }

    @Test func handlesEmptyStringGracefully() {
        // 空文字でもクラッシュせず画像 or nil を返す (例外を投げない)。
        _ = QRCodeGenerator.image(from: "")
    }
}
