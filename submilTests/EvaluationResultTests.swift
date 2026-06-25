import Testing
@testable import submil

/// 評価結果 (`EvaluationResult`) の表示用テキストのテスト (#32)。
/// 文言は仕様で変わりうるが「全ケースで非空かつ重複しない」不変条件を担保する。
@Suite struct EvaluationResultTests {
    private let allResults: [EvaluationResult] = [.keep, .reconsider, .cancel]

    @Test func headlineAndAdviceAreNonEmpty() {
        for result in allResults {
            #expect(!result.label.isEmpty)
            #expect(!result.headline.isEmpty)
            #expect(!result.advice.isEmpty)
        }
    }

    @Test func headlinesAreDistinct() {
        let headlines = allResults.map(\.headline)
        #expect(Set(headlines).count == allResults.count)
    }

    @Test func advicesAreDistinct() {
        let advices = allResults.map(\.advice)
        #expect(Set(advices).count == allResults.count)
    }
}

/// 質問 enum が `EvaluationChoice` として汎用ビューに渡せることのテスト。
@Suite struct EvaluationChoiceTests {
    @Test func recencyChoicesAreOrderedBestFirst() {
        // 宣言順 (= 表示順) がスコア降順 (使っている順) であることを確認する。
        let scores = UsageRecency.allCases.map(\.score)
        #expect(scores == scores.sorted(by: >))
    }

    @Test func frequencyChoicesAreOrderedBestFirst() {
        let scores = UsageFrequency.allCases.map(\.score)
        #expect(scores == scores.sorted(by: >))
    }

    @Test func difficultyChoicesAreOrderedBestFirst() {
        let scores = GoneDifficulty.allCases.map(\.score)
        #expect(scores == scores.sorted(by: >))
    }

    @Test func choiceIdMatchesSelf() {
        #expect(UsageRecency.today.id == UsageRecency.today)
        #expect(UsageFrequency.over20.id == UsageFrequency.over20)
        #expect(GoneDifficulty.cannotLive.id == GoneDifficulty.cannotLive)
    }
}
