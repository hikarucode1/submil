import SwiftUI
import SwiftData

/// 「これ要る?」評価フロー (#28-#32)。
/// 導入 → 質問1 (最後に使ったの?) → 質問2 (月に何回?) → 質問3 (無いと困る?) → 結果 を順に進める。
/// 詳細画面から sheet 表示する。結果確定時に `UsageEvaluation` を SwiftData へ保存する。
struct EvaluationFlowView: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .intro
    @State private var recency: UsageRecency?
    @State private var frequency: UsageFrequency?
    @State private var difficulty: GoneDifficulty?
    @State private var result: EvaluationResult?

    private enum Step {
        case intro, recency, frequency, difficulty, result
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(step == .result ? "評価結果" : "これ要る?")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { leadingButton }
                }
        }
        // 質問の途中はスワイプで閉じさせない (誤操作で入力が消えるのを防ぐ)
        .interactiveDismissDisabled(step != .intro && step != .result)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch step {
        case .intro:
            intro
        case .recency:
            EvaluationQuestionView(
                stepIndex: 1,
                totalSteps: 3,
                title: "最後に使ったのはいつ?",
                subtitle: subscription.serviceName,
                choices: UsageRecency.allCases,
                selection: recency
            ) { choice in
                recency = choice
                advance(to: .frequency)
            }
        case .frequency:
            EvaluationQuestionView(
                stepIndex: 2,
                totalSteps: 3,
                title: "月に何回くらい使う?",
                choices: UsageFrequency.allCases,
                selection: frequency
            ) { choice in
                frequency = choice
                advance(to: .difficulty)
            }
        case .difficulty:
            EvaluationQuestionView(
                stepIndex: 3,
                totalSteps: 3,
                title: "無くなったら困る?",
                choices: GoneDifficulty.allCases,
                selection: difficulty
            ) { choice in
                difficulty = choice
                finish(with: choice)
            }
        case .result:
            if let result {
                EvaluationResultView(subscription: subscription, result: result) {
                    dismiss()
                }
            }
        }
    }

    private var intro: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("このサブスク、ちゃんと使えてる?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            Text("3 つの質問に答えるだけ。\n「\(subscription.serviceName)」が今のあなたに必要か、一緒に確かめましょう。")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button { advance(to: .recency) } label: {
                Text("はじめる")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }

    // MARK: - Toolbar

    @ViewBuilder
    private var leadingButton: some View {
        switch step {
        case .intro:
            Button("やめる") { dismiss() }
        case .recency:
            backButton { advance(to: .intro) }
        case .frequency:
            backButton { advance(to: .recency) }
        case .difficulty:
            backButton { advance(to: .frequency) }
        case .result:
            EmptyView()
        }
    }

    private func backButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
        }
        .accessibilityLabel("戻る")
    }

    // MARK: - Transitions

    private func advance(to next: Step) {
        withAnimation { step = next }
    }

    /// 質問3 の回答を受けて評価を確定・保存し、結果画面へ進む。
    private func finish(with difficulty: GoneDifficulty) {
        guard let recency, let frequency else { return }
        let evaluation = UsageEvaluation(
            subscription: subscription,
            lastUsed: recency,
            frequency: frequency,
            difficulty: difficulty
        )
        modelContext.insert(evaluation)
        result = evaluation.result
        advance(to: .result)
    }
}

#Preview {
    EvaluationFlowView(
        subscription: Subscription(
            serviceName: "Netflix",
            amount: 1490,
            billingCycle: .monthly,
            billingDay: 15,
            category: .video
        )
    )
    .modelContainer(for: Subscription.self, inMemory: true)
}
