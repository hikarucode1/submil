import Foundation
#if canImport(FirebaseCore)
import FirebaseCore
#endif

/// Firebase の初期化を担う (#47)。
///
/// `submilApp` (App エントリ) には手を入れず、`RootView` の `.task` から一度だけ呼ぶ方針
/// (AdMob / SampleData と同じ起動フック)。`FirebaseCore` 未追加の環境では no-op。
///
/// - `GoogleService-Info.plist` がバンドルに必要 (Mac で配置、`docs/setup/firebase-analytics.md`)。
/// - `FirebaseApp.configure()` は多重呼び出しで警告を出すため、未構成時のみ実行する。
enum FirebaseStarter {
    /// アプリ起動後に一度だけ Firebase を構成する。
    static func configureIfNeeded() {
        #if canImport(FirebaseCore)
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
        #endif
    }
}
