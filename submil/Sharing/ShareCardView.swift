import SwiftUI

/// 節約額シェアカード (#38)。ImageRenderer で UIImage 化して共有する。
/// レンダリング前提のため固定サイズ・固定レイアウトで組む。
struct ShareCardView: View {
    let content: SavingsShareContent

    /// カードの基準サイズ (pt)。ImageRenderer.scale で実ピクセルに拡大する。
    static let side: CGFloat = 360

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer(minLength: 0)
            savings
            Spacer(minLength: 0)
            footer
        }
        .padding(28)
        .frame(width: Self.side, height: Self.side)
        .background(
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.55, blue: 0.36), Color(red: 0.02, green: 0.38, blue: 0.28)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - パーツ

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "scissors")
                .font(.title3.bold())
            Text("サブミル")
                .font(.title3.bold())
            Spacer()
        }
        .foregroundStyle(.white)
    }

    private var savings: some View {
        VStack(spacing: 6) {
            Text("年間")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(content.amountText)
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundStyle(.white)
            Text("節約しました！")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(content.subheadline)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity)
    }

    private var footer: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("あなたのサブスク、")
                Text("チャント見てる?")
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.white.opacity(0.9))

            Spacer()

            VStack(spacing: 4) {
                qrCode
                Text("App Storeで")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    @ViewBuilder
    private var qrCode: some View {
        if let qr = QRCodeGenerator.image(from: AppLink.appStoreURL.absoluteString, size: 64) {
            Image(uiImage: qr)
                .interpolation(.none)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(5)
                .background(.white, in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ShareCardView(content: SavingsShareContent(totalAnnualSaving: 38400, cancelledCount: 3))
}
