import Foundation
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

/// App Tracking Transparency (ATT) の許可要求を担う (#46)。
///
/// AdMob (#45) は ATT が「許可」の場合のみ IDFA を用いたパーソナライズ広告を配信できる。
/// 「拒否」でも非パーソナライズ広告は配信されるため、アプリ機能自体は許可有無に依存しない。
///
/// - 説明文は `Info.plist` の `NSUserTrackingUsageDescription`
///   (pbxproj の `INFOPLIST_KEY_NSUserTrackingUsageDescription`) に定義済み。
/// - `AppTrackingTransparency` 未リンクの環境では no-op になり、Linux でもビルドできる。
enum TrackingAuthorization {
    /// 追跡が許可済みか。ATT フレームワークが無い環境では常に未許可扱い。
    static var isAuthorized: Bool {
        #if canImport(AppTrackingTransparency)
        return ATTrackingManager.trackingAuthorizationStatus == .authorized
        #else
        return false
        #endif
    }

    /// ステータスが未決定 (`.notDetermined`) の場合のみ ATT ダイアログを提示し、応答を待つ。
    /// 既に許可/拒否が確定していれば何もしない (Apple はダイアログの再提示を認めない)。
    ///
    /// - 重要: 呼び出し時にアプリが `active` 状態でないとダイアログは表示されない。
    ///   必ず `RootView` で `scenePhase == .active` を確認してから呼ぶこと。
    static func requestIfNeeded() async {
        #if canImport(AppTrackingTransparency)
        guard ATTrackingManager.trackingAuthorizationStatus == .notDetermined else { return }
        await withCheckedContinuation { continuation in
            ATTrackingManager.requestTrackingAuthorization { _ in
                continuation.resume()
            }
        }
        #endif
    }
}
