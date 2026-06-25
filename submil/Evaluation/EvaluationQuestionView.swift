import SwiftUI

/// 評価フローの 1 問を表示する汎用ビュー (#29-#31)。
/// 選択肢をタップすると `onSelect` が呼ばれ、フロー側が次の質問へ進める。
struct EvaluationQuestionView<Choice: EvaluationChoice>: View {
    let stepIndex: Int       // 1 始まり
    let totalSteps: Int
    let title: String
    var subtitle: String?
    let choices: [Choice]
    let selection: Choice?
    let onSelect: (Choice) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            choiceList
            Spacer()
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: Double(stepIndex), total: Double(totalSteps))
                .tint(.accentColor)
            Text("質問 \(stepIndex) / \(totalSteps)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var choiceList: some View {
        VStack(spacing: 12) {
            ForEach(choices) { choice in
                choiceButton(choice)
            }
        }
    }

    private func choiceButton(_ choice: Choice) -> some View {
        let isSelected = selection == choice
        return Button { onSelect(choice) } label: {
            HStack {
                Text(choice.label)
                    .font(.body)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EvaluationQuestionView(
        stepIndex: 1,
        totalSteps: 3,
        title: "最後に使ったのはいつ?",
        subtitle: "Netflix",
        choices: UsageRecency.allCases,
        selection: UsageRecency.within3days,
        onSelect: { _ in }
    )
}
