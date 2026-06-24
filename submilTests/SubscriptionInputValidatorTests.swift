import Foundation
import Testing
@testable import submil

@Suite struct SubscriptionInputValidatorTests {

    // MARK: - 妥当な入力

    @Test func validInputReturnsNoErrors() {
        let errors = SubscriptionInputValidator.validate(
            serviceName: "Netflix",
            amount: 1490,
            billingDay: 15
        )
        #expect(errors.isEmpty)
        #expect(SubscriptionInputValidator.isValid(serviceName: "Netflix", amount: 1490, billingDay: 15))
    }

    // MARK: - serviceName

    @Test func emptyServiceNameIsError() {
        let errors = SubscriptionInputValidator.validate(serviceName: "", amount: 1000, billingDay: 1)
        #expect(errors == [.emptyServiceName])
    }

    @Test func whitespaceOnlyServiceNameIsError() {
        // 空白のみは trim 後に空 → エラー
        let errors = SubscriptionInputValidator.validate(serviceName: "　 \n", amount: 1000, billingDay: 1)
        #expect(errors == [.emptyServiceName])
    }

    @Test func serviceNameWithSurroundingSpacesIsValid() {
        // 前後に空白があっても中身があれば妥当
        let errors = SubscriptionInputValidator.validate(serviceName: "  Spotify  ", amount: 980, billingDay: 10)
        #expect(errors.isEmpty)
    }

    // MARK: - amount

    @Test func zeroAmountIsError() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 0, billingDay: 1)
        #expect(errors == [.nonPositiveAmount])
    }

    @Test func negativeAmountIsError() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: -100, billingDay: 1)
        #expect(errors == [.nonPositiveAmount])
    }

    @Test func amountOfOneIsValid() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 1, billingDay: 1)
        #expect(errors.isEmpty)
    }

    // MARK: - billingDay (境界 1...31)

    @Test func billingDayBelowRangeIsError() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 1000, billingDay: 0)
        #expect(errors == [.billingDayOutOfRange])
    }

    @Test func billingDayAboveRangeIsError() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 1000, billingDay: 32)
        #expect(errors == [.billingDayOutOfRange])
    }

    @Test func billingDayLowerBoundIsValid() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 1000, billingDay: 1)
        #expect(errors.isEmpty)
    }

    @Test func billingDayUpperBoundIsValid() {
        let errors = SubscriptionInputValidator.validate(serviceName: "X", amount: 1000, billingDay: 31)
        #expect(errors.isEmpty)
    }

    // MARK: - 複数エラー (フィールド順)

    @Test func multipleErrorsAreReturnedInFieldOrder() {
        let errors = SubscriptionInputValidator.validate(serviceName: "", amount: 0, billingDay: 99)
        #expect(errors == [.emptyServiceName, .nonPositiveAmount, .billingDayOutOfRange])
        // 先頭エラーの field がフォーカス対象
        #expect(errors.first?.field == .serviceName)
    }

    // MARK: - エラーの field マッピング

    @Test func errorFieldMapping() {
        #expect(SubscriptionInputError.emptyServiceName.field == .serviceName)
        #expect(SubscriptionInputError.nonPositiveAmount.field == .amount)
        #expect(SubscriptionInputError.billingDayOutOfRange.field == .billingDay)
    }
}
