import Foundation
import SwiftData

@Model
final class UsageEvaluation {
    @Attribute(.unique) var id: UUID
    var subscription: Subscription?
    var evaluatedAt: Date

    var lastUsedRecency: UsageRecency
    var usageFrequency: UsageFrequency
    var difficultyIfGone: GoneDifficulty

    var result: EvaluationResult

    init(
        subscription: Subscription,
        lastUsed: UsageRecency,
        frequency: UsageFrequency,
        difficulty: GoneDifficulty
    ) {
        self.id = UUID()
        self.subscription = subscription
        self.evaluatedAt = .now
        self.lastUsedRecency = lastUsed
        self.usageFrequency = frequency
        self.difficultyIfGone = difficulty
        self.result = Self.calculateResult(
            recency: lastUsed,
            frequency: frequency,
            difficulty: difficulty
        )
    }

    /// 3 軸スコアの合算で推奨アクションを決定
    static func calculateResult(
        recency: UsageRecency,
        frequency: UsageFrequency,
        difficulty: GoneDifficulty
    ) -> EvaluationResult {
        let score = recency.score + frequency.score + difficulty.score
        switch score {
        case 9...:  return .keep
        case 5...8: return .reconsider
        default:    return .cancel
        }
    }
}
