import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds

/// AdMob アダプティブバナーを SwiftUI へブリッジする (#45)。
///
/// API 名は **Google Mobile Ads SDK v12 以降**の Swift API (GAD プレフィックスなし) に準拠。
/// v11 以前を解決した場合は `BannerView`→`GADBannerView`、`MobileAds`→`GADMobileAds`、
/// `AdSize`→`GADAdSize`、`Request`→`GADRequest` と読み替える。
private struct AdaptiveBannerView: UIViewRepresentable {
    let unitID: String
    /// バナーを敷く横幅。アダプティブサイズの算出に使う。
    let width: CGFloat

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adaptiveSize)
        banner.adUnitID = unitID
        banner.rootViewController = Self.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ banner: BannerView, context: Context) {
        let size = adaptiveSize
        if banner.adSize.size.width != size.size.width {
            banner.adSize = size
            banner.load(Request())
        }
    }

    private var adaptiveSize: AdSize {
        // 端末幅いっぱいのアンカー型アダプティブバナー。
        currentOrientationAnchoredAdaptiveBanner(width: width)
    }

    /// 現在アクティブな UIWindowScene の rootViewController を解決する。
    private static var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow?
            .rootViewController
    }
}
#endif

/// ホーム画面下部に敷くバナー広告のコンテナ (#45)。
///
/// `GoogleMobileAds` パッケージが未追加の環境では `#if canImport` により空ビューになるため、
/// SPM パッケージ追加前でもプロジェクトはビルドできる (段階的統合)。
struct BannerAdContainer: View {
    /// 標準バナー高さ (50pt)。アダプティブでもおおよそこの高さに収まる。
    private let bannerHeight: CGFloat = 50

    var body: some View {
        #if canImport(GoogleMobileAds)
        GeometryReader { proxy in
            AdaptiveBannerView(unitID: AdConfig.bannerUnitID, width: proxy.size.width)
                .frame(width: proxy.size.width, height: bannerHeight)
        }
        .frame(height: bannerHeight)
        #else
        EmptyView()
        #endif
    }
}
