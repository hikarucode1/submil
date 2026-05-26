import Foundation
import Testing
@testable import submil

/// `UsageEvaluation.calculateResult` の境界値テスト。
///
/// 実装スコア区分:
/// - 9 以上          → keep
/// - 5 ... 8         → reconsider
/// - それ以外 (0..4) → cancel
///
/// Issue 本文の `2+2+1` 等のスコア表記は概念値。`UsageFrequency` には値 2 が
/// 存在しないため、実 enum で同合計スコアになる組合せでテストする。
@Suite struct UsageEvaluationTests {
    // MARK: keep 領域

    /// 最高スコア 15 (5+5+5)
    @Test func maxScoreReturnsKeep() {
        let result = UsageEvaluation.calculateResult(
            recency: .today,        // 5
            frequency: .over20,     // 5
            difficulty: .cannotLive // 5
        )
        #expect(result == .keep)
    }

    /// keep の下限スコア 9 (5+3+1)
    @Test func boundaryScore9ReturnsKeep() {
        let result = UsageEvaluation.calculateResult(
            recency: .today,        // 5
            frequency: .around5,    // 3
            difficulty: .notReally  // 1
        )
        #expect(result == .keep)
    }

    // MARK: reconsider 領域

    /// reconsider の上限スコア 8 (5+3+0)
    @Test func boundaryScore8ReturnsReconsider() {
        let result = UsageEvaluation.calculateResult(
            recency: .today,        // 5
            frequency: .around5,    // 3
            difficulty: .notAtAll   // 0
        )
        #expect(result == .reconsider)
    }

    /// reconsider の下限スコア 5 (4+1+0)
    @Test func boundaryScore5ReturnsReconsider() {
        let result = UsageEvaluation.calculateResult(
            recency: .within3days,  // 4
            frequency: .few,        // 1
            difficulty: .notAtAll   // 0
        )
        #expect(result == .reconsider)
    }

    /// reconsider 内の別組合せ (3+1+1 = 5)
    @Test func boundaryScore5AlternateCompositionReturnsReconsider() {
        let result = UsageEvaluation.calculateResult(
            recency: .withinWeek,   // 3
            frequency: .few,        // 1
            difficulty: .notReally  // 1
        )
        #expect(result == .reconsider)
    }

    // MARK: cancel 領域

    /// cancel の上限スコア 4 (4+0+0)
    @Test func boundaryScore4ReturnsCancel() {
        let result = UsageEvaluation.calculateResult(
            recency: .within3days,  // 4
            frequency: .rarely,     // 0
            difficulty: .notAtAll   // 0
        )
        #expect(result == .cancel)
    }

    /// cancel 内の別組合せ (2+1+1 = 4)
    @Test func boundaryScore4AlternateCompositionReturnsCancel() {
        let result = UsageEvaluation.calculateResult(
            recency: .withinMonth,  // 2
            frequency: .few,        // 1
            difficulty: .notReally  // 1
        )
        #expect(result == .cancel)
    }

    /// 最低スコア 0 (0+0+0)
    @Test func minScoreReturnsCancel() {
        let result = UsageEvaluation.calculateResult(
            recency: .over,         // 0
            frequency: .rarely,     // 0
            difficulty: .notAtAll   // 0
        )
        #expect(result == .cancel)
    }
}
