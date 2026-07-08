import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// AdMob SDK の初期化を担う (#45)。
///
/// `submilApp` (App エントリ) には手を入れず、`RootView` の `.task` から一度だけ呼ぶ方針。
/// `GoogleMobileAds` 未追加の環境では no-op になり、SPM パッケージ追加前でもビルドできる。
///
/// 注意 (#46): 本来 ATT (App Tracking Transparency) の許可要求を経てから SDK を開始/計測するのが望ましい。
/// ATT ダイアログ実装 (#46) と統合する際は、`startIfNeeded()` の呼び出しを ATT 応答後へ寄せること。
enum AdMobStarter {
    /// アプリ起動後に一度だけ SDK を初期化する。多重呼び出しは SDK 側で冪等。
    static func startIfNeeded() {
        #if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: nil)
        #endif
    }
}
