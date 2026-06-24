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
                Text(subscription.serviceName)
                    .font(.body)
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
    List {
        SubscriptionRow(
            subscription: Subscription(
                serviceName: "Netflix",
                amount: 1490,
                billingCycle: .monthly,
                billingDay: 15,
                category: .video
            )
        )
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
