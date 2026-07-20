import Foundation
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

/// AdMob SDK の初期化を担う (#45)。
///
/// `submilApp` (App エントリ) には手を入れず、`RootView` から呼ぶ方針。
/// 呼び出し元は view のライフサイクルで再実行され得るため、多重呼び出しの抑止はここで保証する。
/// `GoogleMobileAds` 未追加の環境では no-op になり、SPM パッケージ追加前でもビルドできる。
@MainActor
enum AdMobStarter {
    private static var hasStarted = false

    /// ATT (#46) の許可要求を経てから SDK を初期化する。通常はこちらを使う。
    /// Google 推奨どおり、ATT の結果 (許可/拒否) に関わらず応答後に SDK を開始する。
    /// - 重要: ATT ダイアログはアプリが `active` の時のみ表示されるため、
    ///   `RootView` で `scenePhase == .active` を確認してから呼ぶこと。
    static func startAfterTrackingAuthorization() async {
        await TrackingAuthorization.requestIfNeeded()
        startIfNeeded()
    }

    /// アプリ起動後に一度だけ SDK を初期化する。2 回目以降の呼び出しは no-op。
    static func startIfNeeded() {
        #if canImport(GoogleMobileAds)
        guard !hasStarted else { return }
        hasStarted = true
        MobileAds.shared.start(completionHandler: nil)
        #endif
    }
}
