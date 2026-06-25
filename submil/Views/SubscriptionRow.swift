import SwiftUI

/// ホーム一覧の1行 (Issue #22)。
/// emoji + サービス名 + 次回支払日 + 月額換算を表示する。
/// タップでの詳細遷移・スワイプ削除は List 側 (HomeView #19) で配線する。
struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            Text(subscription.category.emoji)
                .font(.title2)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(subscription.serviceName)
                        .font(.body)
                    if let result = subscription.latestRecommendation {
                        // 直近の「これ要る?」評価結果を色 + アイコンで示す (#33 の延長)。
                        // 未評価 (nil) のときは何も出さない。
                        Image(systemName: result.systemImage)
                            .font(.caption2)
                            .foregroundStyle(result.color)
                            .accessibilityLabel("評価結果: \(result.label)")
                    }
                }
                Text("次回 \(subscription.nextBillingDate.formatted(.dateTime.month().day()))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("¥\(subscription.monthlyEquivalent.formatted()) / 月")
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    // 評価済み (cancel) の行をプレビューでバッジ付きで確認する
    let netflix: Subscription = {
        let subscription = Subscription(
            serviceName: "Netflix",
            amount: 1490,
            billingCycle: .monthly,
            billingDay: 15,
            category: .video
        )
        subscription.evaluations = [
            UsageEvaluation(subscription: subscription, lastUsed: .over, frequency: .rarely, difficulty: .notAtAll)
        ]
        return subscription
    }()

    List {
        SubscriptionRow(subscription: netflix)
        SubscriptionRow(
            subscription: Subscription(
                serviceName: "Spotify (年額)",
                amount: 9800,
                billingCycle: .yearly,
                billingDay: 1,
                category: .music
            )
        )
    }
}
