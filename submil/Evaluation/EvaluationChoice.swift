import Foundation

/// 評価フローの 1 問で提示する選択肢。3 つの質問 enum が共通で満たす契約。
/// `EvaluationQuestionView` を enum ごとに書き分けず汎用化するために用いる。
protocol EvaluationChoice: CaseIterable, Hashable, Identifiable where AllCases == [Self] {
    /// 選択肢のラベル (例: 「今日使った」)
    var label: String { get }
    /// スコア。合算して推奨アクションを決める (`UsageEvaluation.calculateResult`)
    var score: Int { get }
}

extension EvaluationChoice {
    var id: Self { self }
}

// 既存の質問 enum を選択肢として扱えるようにする。
// label / score は各 enum 側で既に定義済み (Models/Enums.swift)。
extension UsageRecency: EvaluationChoice {}
extension UsageFrequency: EvaluationChoice {}
extension GoneDifficulty: EvaluationChoice {}
