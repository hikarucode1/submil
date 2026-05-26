import Foundation
import Testing
@testable import submil

@Suite struct SubscriptionTests {
    private func makeSubscription(amount: Int, cycle: BillingCycle) -> Subscription {
        Subscription(
            serviceName: "TestService",
            amount: amount,
            billingCycle: cycle,
            billingDay: 1,
            category: .other
        )
    }

    // MARK: monthly 980 円

    @Test func monthly980YenMonthlyEquivalent() {
        #expect(makeSubscription(amount: 980, cycle: .monthly).monthlyEquivalent == 980)
    }

    @Test func monthly980YenYearlyEquivalent() {
        #expect(makeSubscription(amount: 980, cycle: .monthly).yearlyEquivalent == 11760)
    }

    // MARK: yearly 9800 円

    @Test func yearly9800YenMonthlyEquivalentTruncates() {
        // 9800 / 12 = 816.666... → Int 切り捨てで 816
        #expect(makeSubscription(amount: 9800, cycle: .yearly).monthlyEquivalent == 816)
    }

    @Test func yearly9800YenYearlyEquivalent() {
        #expect(makeSubscription(amount: 9800, cycle: .yearly).yearlyEquivalent == 9800)
    }

    // MARK: quarterly 3000 円

    @Test func quarterly3000YenMonthlyEquivalent() {
        #expect(makeSubscription(amount: 3000, cycle: .quarterly).monthlyEquivalent == 1000)
    }

    @Test func quarterly3000YenYearlyEquivalent() {
        #expect(makeSubscription(amount: 3000, cycle: .quarterly).yearlyEquivalent == 12000)
    }

    // MARK: エッジ — amount = 0

    @Test func zeroAmountReturnsZeroAcrossAllCycles() {
        for cycle in BillingCycle.allCases {
            let subscription = makeSubscription(amount: 0, cycle: cycle)
            #expect(subscription.monthlyEquivalent == 0)
            #expect(subscription.yearlyEquivalent == 0)
        }
    }

    // MARK: エッジ — amount = 1

    @Test func oneYenMonthlyCycle() {
        let subscription = makeSubscription(amount: 1, cycle: .monthly)
        #expect(subscription.monthlyEquivalent == 1)
        #expect(subscription.yearlyEquivalent == 12)
    }

    @Test func oneYenYearlyCycleMonthlyTruncatesToZero() {
        // 1 / 12 = 0.083... → Int 切り捨てで 0
        let subscription = makeSubscription(amount: 1, cycle: .yearly)
        #expect(subscription.monthlyEquivalent == 0)
        #expect(subscription.yearlyEquivalent == 1)
    }

    @Test func oneYenQuarterlyCycleMonthlyTruncatesToZero() {
        // 1 / 3 = 0.333... → Int 切り捨てで 0
        let subscription = makeSubscription(amount: 1, cycle: .quarterly)
        #expect(subscription.monthlyEquivalent == 0)
        #expect(subscription.yearlyEquivalent == 4)
    }
}
