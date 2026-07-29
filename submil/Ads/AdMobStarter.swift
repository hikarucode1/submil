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
        // AdMob 独自のクラッシュレポート (GADRegisterSignalHandlers) を無効化する (#48)。
        // これを呼ばないと GMA SDK がシグナル/例外ハンドラを登録し、Firebase Crashlytics の
        // ハンドラと競合してクラッシュ (fatalError = SIGILL/SIGTRAP 等) が Crashlytics に届かない
        // (起動ログの "non-Crashlytics handler ... will interfere with reporting" 警告の実害)。
        // start() 前に呼ぶこと。広告配信には影響しない。
        MobileAds.shared.disableSDKCrashReporting()
        MobileAds.shared.start(completionHandler: nil)
        #endif
    }
}
