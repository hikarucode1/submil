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
        // 起動直後は scene が foregroundActive 前で rootViewController が nil のことがあるため、
        // update 側でも補完する (nil のままだと広告タップ/全画面遷移が機能しない)。
        if banner.rootViewController == nil {
            banner.rootViewController = Self.rootViewController
        }
        // アンカー型アダプティブの再ロードはサイズが実際に変わったとき (=回転など) に限る。
        // Google のガイドライン上、回転時は新しいサイズで load し直すのが正道。
        let size = adaptiveSize
        if !banner.adSize.size.equalTo(size.size) {
            banner.adSize = size
            banner.load(Request())
        }
    }

    private var adaptiveSize: AdSize {
        // 端末幅いっぱいのアンカー型アダプティブバナー。
        currentOrientationAnchoredAdaptiveBanner(width: width)
    }

    /// 現在アクティブな UIWindowScene の rootViewController を解決する。
    /// 起動直後などで foregroundActive な scene がまだ無い場合は最初の scene にフォールバックする。
    private static var rootViewController: UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        let window = scene?.keyWindow ?? scene?.windows.first
        return window?.rootViewController
    }
}
#endif

/// ホーム画面下部に敷くバナー広告のコンテナ (#45)。
///
/// `GoogleMobileAds` パッケージが未追加の環境では `#if canImport` により空ビューになるため、
/// SPM パッケージ追加前でもプロジェクトはビルドできる (段階的統合)。
struct BannerAdContainer: View {
    #if canImport(GoogleMobileAds)
    /// アダプティブバナーの実高さ。幅確定後に AdSize から算出する (機種により 50〜90pt 程度)。
    /// 固定 50pt だと iPad 等で背の高い広告がクリップされるため、SDK の返す高さに追従させる。
    @State private var bannerHeight: CGFloat = 50

    var body: some View {
        #if DEBUG
        // スクリーンショット撮影 (#50) 時は広告未初期化で空枠になるため敷かない。
        if SnapshotSupport.isActive {
            EmptyView()
        } else {
            bannerBody
        }
        #else
        bannerBody
        #endif
    }

    private var bannerBody: some View {
        GeometryReader { proxy in
            AdaptiveBannerView(unitID: AdConfig.bannerUnitID, width: proxy.size.width)
                .frame(width: proxy.size.width, height: bannerHeight)
                .onAppear { updateHeight(width: proxy.size.width) }
                .onChange(of: proxy.size.width) { _, newWidth in
                    updateHeight(width: newWidth)
                }
        }
        .frame(height: bannerHeight)
    }

    private func updateHeight(width: CGFloat) {
        guard width > 0 else { return }
        bannerHeight = currentOrientationAnchoredAdaptiveBanner(width: width).size.height
    }
    #else
    var body: some View {
        EmptyView()
    }
    #endif
}
