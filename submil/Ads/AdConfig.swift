import Foundation

/// AdMob の広告ユニット/アプリ ID を一元管理する (#45)。
///
/// - 重要: デフォルトは Google 公式の**テスト ID**。実機/シミュレータでテスト広告のみ表示され、
///   誤って本番在庫を消費したり無効トラフィックでアカウント停止になるのを防ぐ。
/// - 本番リリース前に `productionBannerUnitID` / `productionApplicationID` を実際の値へ置換し、
///   併せて `Info.plist` の `GADApplicationIdentifier` を本番アプリ ID に更新すること。
/// - `useTestAds` は DEBUG ビルドで自動的に true。Release で本番 ID を使う。
enum AdConfig {
    /// Google 公式のバナー用テスト広告ユニット ID。
    /// https://developers.google.com/admob/ios/test-ads
    static let testBannerUnitID = "ca-app-pub-3940256099942544/2934735716"

    /// Google 公式のテスト用アプリ ID (`Info.plist` の `GADApplicationIdentifier` に設定する値)。
    static let testApplicationID = "ca-app-pub-3940256099942544~1458002511"

    /// 本番のバナー広告ユニット ID。AdMob 管理画面で発行後に置換する。
    /// TODO(#45): 本番値へ差し替え。
    static let productionBannerUnitID = "ca-app-pub-0000000000000000/0000000000"

    /// 本番のアプリ ID。AdMob 管理画面で発行後に置換し、`Info.plist` にも反映する。
    /// TODO(#45): 本番値へ差し替え。
    static let productionApplicationID = "ca-app-pub-0000000000000000~0000000000"

    /// DEBUG ビルドではテスト広告を強制する。
    static var useTestAds: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// 実際に読み込むバナー広告ユニット ID。
    ///
    /// 本番 ID がプレースホルダーのまま (差し替え忘れ) の場合の扱い:
    /// - DEBUG: `assertionFailure` で開発時に大きく検知する。
    /// - Release (TestFlight / App Store): クラッシュさせず空文字を返し、広告ロードを不成立にする
    ///   (バナー非表示)。`precondition` と違い実ユーザーをクラッシュさせない graceful degradation。
    ///   ※ テスト ID を本番配信に使うのは AdMob ポリシー違反のため、フォールバックは空とする。
    ///   併せて `CrashReporter.record` の非致命記録で差し替え漏れを Crashlytics から検知できるようにする。
    static var bannerUnitID: String {
        guard !useTestAds else { return testBannerUnitID }
        if productionBannerUnitID.contains("0000000000000000") {
            assertionFailure(
                "productionBannerUnitID がプレースホルダーのままです。AdMob 管理画面で発行した本番 ID に差し替えてください (docs/setup/admob.md)。"
            )
            CrashReporter.record(AdConfigError.placeholderBannerUnitID)
            return ""
        }
        return productionBannerUnitID
    }
}

/// AdConfig の設定不備を Crashlytics 非致命として集計するためのエラー (#45/#48)。
enum AdConfigError: Error, CustomNSError {
    /// Release ビルドで本番バナー ID がプレースホルダーのまま (バナー非表示で継続)。
    case placeholderBannerUnitID

    static let errorDomain = "jp.submil.AdConfigError"

    var errorCode: Int {
        switch self {
        case .placeholderBannerUnitID: return 1
        }
    }

    var errorUserInfo: [String: Any] {
        switch self {
        case .placeholderBannerUnitID:
            return [NSLocalizedDescriptionKey: "productionBannerUnitID がプレースホルダーのまま Release 配信されている (docs/setup/admob.md)"]
        }
    }
}
