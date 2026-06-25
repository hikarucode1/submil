import SwiftUI
import SwiftData

/// サブスク詳細画面 (#27 本実装)。
/// 基本情報・直近の評価結果・「これ要る?」評価フローの起点 (#28-#32)・評価履歴 (#33) を表示する。
struct SubscriptionDetailView: View {
    let subscription: Subscription

    @State private var showingEvaluation = false

    var body: some View {
        List {
            if let result = subscription.latestRecommendation {
                recommendationSection(result)
            }
            basicInfoSection
            evaluateSection
            if !subscription.evaluations.isEmpty {
                historySection
            }
            if let memo = subscription.memo, !memo.isEmpty {
                Section("メモ") {
                    Text(memo)
                }
            }
        }
        .navigationTitle(subscription.serviceName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEvaluation) {
            EvaluationFlowView(subscription: subscription)
        }
    }

    // MARK: - Sections

    private func recommendationSection(_ result: EvaluationResult) -> some View {
        Section {
            HStack(spacing: 12) {
                Image(systemName: result.systemImage)
                    .font(.title2)
                    .foregroundStyle(result.color)
                VStack(alignment: .leading, spacing: 2) {
                    Text(result.label)
                        .font(.headline)
                        .foregroundStyle(result.color)
                    Text("直近の評価結果")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var basicInfoSection: some View {
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
    }

    private var evaluateSection: some View {
        Section {
            Button { showingEvaluation = true } label: {
                Label(
                    subscription.evaluations.isEmpty ? "「これ要る?」を評価する" : "もう一度評価する",
                    systemImage: "checklist"
                )
            }
        }
    }

    private var historySection: some View {
        Section("評価履歴") {
            ForEach(sortedEvaluations) { evaluation in
                EvaluationHistoryRow(evaluation: evaluation)
            }
        }
    }

    private var sortedEvaluations: [UsageEvaluation] {
        subscription.evaluations.sorted { $0.evaluatedAt > $1.evaluatedAt }
    }
}

/// 評価履歴の 1 行 (#33)。結果・実施日時・回答内容のサマリを表示する。
private struct EvaluationHistoryRow: View {
    let evaluation: UsageEvaluation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Circle()
                    .fill(evaluation.result.color)
                    .frame(width: 10, height: 10)
                Text(evaluation.result.label)
                    .font(.body)
                Spacer()
                Text(evaluation.evaluatedAt.formatted(.dateTime.year().month().day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(answerSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var answerSummary: String {
        [
            evaluation.lastUsedRecency.label,
            evaluation.usageFrequency.label,
            evaluation.difficultyIfGone.label
        ].joined(separator: " ・ ")
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
    .modelContainer(for: Subscription.self, inMemory: true)
}
