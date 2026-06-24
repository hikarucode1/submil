import SwiftUI

/// サブスク詳細画面の雛形 (Issue #25)。
/// MVP は基本情報の表示のみ。「これ要る?」評価フローは M4、解約は M5 で追加する。
struct SubscriptionDetailView: View {
    let subscription: Subscription

    var body: some View {
        List {
            Section("基本情報") {
                LabeledContent("サービス名", value: subscription.serviceName)
                LabeledContent("カテゴリ", value: "\(subscription.category.emoji) \(subscription.category.displayName)")
                LabeledContent("金額") {
                    Text("¥\(subscription.amount.formatted()) / \(subscription.billingCycle.displayName)")
                }
                LabeledContent("月額換算", value: "¥\(subscription.monthlyEquivalent.formatted())")
                LabeledContent("年額換算", value: "¥\(subscription.yearlyEquivalent.formatted())")
                LabeledContent("次回支払日", value: subscription.nextBillingDate.formatted(.dateTime.year().month().day()))
                LabeledContent("利用開始日", value: subscription.startedAt.formatted(.dateTime.year().month().day()))
            }

            if let memo = subscription.memo, !memo.isEmpty {
                Section("メモ") {
                    Text(memo)
                }
            }

            Section {
                Text("「これ要る?」評価や解約の記録は今後のアップデートで追加されます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(subscription.serviceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SubscriptionDetailView(
            subscription: Subscription(
                serviceName: "Netflix",
                amount: 1490,
                billingCycle: .monthly,
                billingDay: 15,
                category: .video
            )
        )
    }
}
