import SwiftUI

/// 評価結果画面 (#32)。推奨アクション・アドバイス・(解約系なら) 年間節約額を表示する。
struct EvaluationResultView: View {
    let subscription: Subscription
    let result: EvaluationResult
    let onDone: () -> Void

    /// 学割プラン (#42)。reconsider/cancel のとき乗り換え提案として出す。
    @State private var studentPlan: StudentPlan?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: result.systemImage)
                .font(.system(size: 64))
                .foregroundStyle(result.color)

            VStack(spacing: 8) {
                Text(result.headline)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                Text(result.label)
                    .font(.headline)
                    .foregroundStyle(result.color)
            }

            Text(result.advice)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if result != .keep {
                savingsHint
                if let studentPlan {
                    StudentPlanBanner(plan: studentPlan)
                }
            }

            Spacer()

            Button(action: onDone) {
                Text("完了")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .task {
            // 解約・見直し提案のときだけ学割プランを引く (keep のときは出さない)。
            guard result != .keep else { return }
            // stale-while-revalidate: 同梱を即時反映し、背景でリモート最新へ更新する。
            let serviceId = subscription.masterServiceId
            studentPlan = StudentPlanCatalog.plan(forServiceId: serviceId, in: StudentPlanCatalog.loadBundled())
            let latest = await StudentPlanCatalog.loadLatest()
            studentPlan = StudentPlanCatalog.plan(forServiceId: serviceId, in: latest)
        }
    }

    /// 解約した場合の年間節約額。reconsider / cancel のとき行動を後押しする。
    private var savingsHint: some View {
        VStack(spacing: 4) {
            Text("解約すると年間")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("¥\(subscription.yearlyEquivalent.formatted()) 節約")
                .font(.title3.bold())
                .foregroundStyle(result.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(result.color.opacity(0.1))
        )
    }
}

#Preview("cancel") {
    EvaluationResultView(
        subscription: Subscription(
            serviceName: "Netflix",
            amount: 1490,
            billingCycle: .monthly,
            billingDay: 15,
            category: .video
        ),
        result: .cancel,
        onDone: {}
    )
}

#Preview("keep") {
    EvaluationResultView(
        subscription: Subscription(
            serviceName: "Spotify",
            amount: 980,
            billingCycle: .monthly,
            billingDay: 1,
            category: .music
        ),
        result: .keep,
        onDone: {}
    )
}
