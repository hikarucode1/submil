import Foundation
#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

/// Firebase Crashlytics ラッパー (#48)。
///
/// Crashlytics は `FirebaseApp.configure()` (#47, `FirebaseStarter`) 後に自動で有効化される
/// ため明示的な初期化は不要。本型は非致命エラーの記録・パンくずログ・診断キー設定を集約する。
/// `#if canImport(FirebaseCrashlytics)` ガードにより SDK 未追加の環境 (Linux / CI) では no-op。
enum CrashReporter {
    /// パンくずログ。クラッシュ時のレポートに時系列で添付され、直前の状況把握に使う。
    static func log(_ message: String) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().log(message)
        #endif
    }

    /// 非致命エラーを記録する (アプリは継続)。Crashlytics 上では non-fatal として集計される。
    static func record(_ error: Error) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error)
        #endif
    }

    /// クラッシュレポートに添える診断用のカスタムキー。
    static func setCustomValue(_ value: Any, forKey key: String) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        #endif
    }

    #if DEBUG
    /// 動作確認用の意図的クラッシュ (#48)。DEBUG ビルドのみ。
    /// クラッシュ後、**次回起動時**に Crashlytics へレポートが送信される。
    /// 検証手順は `docs/setup/crashlytics.md` を参照。
    static func testCrash() -> Never {
        fatalError("Crashlytics test crash (#48)")
    }
    #endif
}
