import Foundation
import Testing
@testable import submil

@Suite struct SavingsShareContentTests {
    // MARK: 金額・見出しの整形

    @Test func amountTextHasYenAndGrouping() {
        let content = SavingsShareContent(totalAnnualSaving: 38400, cancelledCount: 3)
        #expect(content.amountText == "¥38,400")
    }

    @Test func headlineEmbedsAmount() {
        let content = SavingsShareContent(totalAnnualSaving: 12000, cancelledCount: 1)
        #expect(content.headline == "年間 ¥12,000 節約!")
    }

    // MARK: 件数のサブ見出し

    @Test func subheadlineShowsCountWhenPositive() {
        let content = SavingsShareContent(totalAnnualSaving: 12000, cancelledCount: 2)
        #expect(content.subheadline == "2件のサブスクを見直しました")
    }

    @Test func subheadlineOmitsCountWhenZero() {
        let content = SavingsShareContent(totalAnnualSaving: 12000, cancelledCount: 0)
        #expect(content.subheadline == "サブスクを見直しました")
    }

    // MARK: シェアテキスト

    @Test func shareTextContainsAmountHashtagAndURL() {
        let content = SavingsShareContent(totalAnnualSaving: 38400, cancelledCount: 3)
        #expect(content.shareText.contains("¥38,400"))
        #expect(content.shareText.contains("#サブミル"))
        #expect(content.shareText.contains(AppLink.appStoreURL.absoluteString))
    }

    // MARK: 負値のサニタイズ

    @Test func negativeInputsAreClampedToZero() {
        let content = SavingsShareContent(totalAnnualSaving: -500, cancelledCount: -3)
        #expect(content.totalAnnualSaving == 0)
        #expect(content.cancelledCount == 0)
        #expect(content.amountText == "¥0")
    }
}
