#if DEBUG
import Foundation
import SwiftData
import UIKit

/// App Store 用スクリーンショット (#50) を fastlane snapshot で自動撮影するための支援。
///
/// - 有効化は起動引数 `UITEST_SNAPSHOT` の有無で判定する (UITest 側で付与)。
/// - このファイルは丸ごと `#if DEBUG` のため、Release ビルドには一切含まれない。
///   スナップショットモードが本番で誤起動することはない。
enum SnapshotSupport {
    /// スナップショット撮影モードで起動しているか。
    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("UITEST_SNAPSHOT")
    }

    /// 撮影用に UI アニメーションを止める (待ち時間の削減 + フレーム安定化)。
    @MainActor
    static func prepareUIIfNeeded() {
        guard isActive else { return }
        UIView.setAnimationsEnabled(false)
    }

    /// 訴求力のあるデモデータを投入する。冪等 (既にデータがあれば何もしない)。
    ///
    /// - 合計月額・年間・累計節約額バナー・カテゴリの多様さが一目で伝わる構成にしている。
    @MainActor
    static func seed(into context: ModelContext) {
        guard isActive else { return }
        let existing = try? context.fetch(FetchDescriptor<Subscription>())
        guard existing?.isEmpty ?? true else { return }

        // 登録中サブスク (アクティブ)。合計が「¥6,000/月」前後に収まるよう調整。
        let active: [(String, Int, BillingCycle, Int, SubscriptionCategory)] = [
            ("Netflix",           1_490, .monthly, 15, .video),
            ("Spotify",             980, .monthly,  1, .music),
            ("YouTube Premium",   1_280, .monthly, 20, .video),
            ("iCloud+ 200GB",      400, .monthly,  8, .storage),
            ("Kindle Unlimited",   980, .monthly, 25, .learning),
            ("Adobe Creative",   26_160, .yearly, 10, .creative),
        ]
        for (name, amount, cycle, day, category) in active {
            context.insert(
                Subscription(serviceName: name, amount: amount, billingCycle: cycle, billingDay: day, category: category)
            )
        }

        // 評価済みの一件 (詳細画面/評価結果の見栄え用)。
        if let netflix = try? context.fetch(FetchDescriptor<Subscription>()).first(where: { $0.serviceName == "Netflix" }) {
            context.insert(
                UsageEvaluation(subscription: netflix, lastUsed: .today, frequency: .over20, difficulty: .cannotLive)
            )
        }

        // 解約済み (累計節約額バナーを光らせる)。表示上は非アクティブにして一覧から除く。
        let cancelledMonthly = 1_200
        let cancelled = Subscription(serviceName: "使ってない動画サブスク", amount: cancelledMonthly, billingCycle: .monthly, billingDay: 3, category: .video)
        cancelled.isActive = false
        context.insert(cancelled)
        context.insert(
            CancellationLog(from: cancelled, reason: .unused, note: "3ヶ月ログインしていなかった")
        )
    }
}
#endif
