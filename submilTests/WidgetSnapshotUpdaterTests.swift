import Foundation
import Testing
@testable import submil

@Suite struct WidgetSnapshotUpdaterTests {
    private func makeSubscription(
        amount: Int,
        cycle: BillingCycle = .monthly,
        isActive: Bool = true
    ) -> Subscription {
        let subscription = Subscription(
            serviceName: "TestService",
            amount: amount,
            billingCycle: cycle,
            billingDay: 1,
            category: .other
        )
        subscription.isActive = isActive
        return subscription
    }

    @Test func emptyListProducesZeroSnapshot() {
        let snapshot = WidgetSnapshotUpdater.makeSnapshot(from: [])
        #expect(snapshot.monthlyTotalYen == 0)
        #expect(snapshot.activeCount == 0)
    }

    @Test func sumsMonthlyEquivalentAcrossCycles() {
        // monthly 980 + yearly 9800 (→816) + quarterly 3000 (→1000) = 2796
        let subscriptions = [
            makeSubscription(amount: 980, cycle: .monthly),
            makeSubscription(amount: 9800, cycle: .yearly),
            makeSubscription(amount: 3000, cycle: .quarterly),
        ]
        let snapshot = WidgetSnapshotUpdater.makeSnapshot(from: subscriptions)
        #expect(snapshot.monthlyTotalYen == 2796)
        #expect(snapshot.activeCount == 3)
    }

    @Test func excludesInactiveSubscriptions() {
        let subscriptions = [
            makeSubscription(amount: 980),
            makeSubscription(amount: 1200, isActive: false),
        ]
        let snapshot = WidgetSnapshotUpdater.makeSnapshot(from: subscriptions)
        #expect(snapshot.monthlyTotalYen == 980)
        #expect(snapshot.activeCount == 1)
    }

    @Test func matchesHomeViewMonthlyTotalLogic() {
        // HomeView.monthlyTotal と同一定義 (isActive filter → monthlyEquivalent 総和) の回帰固定
        let subscriptions = [
            makeSubscription(amount: 980),
            makeSubscription(amount: 9800, cycle: .yearly),
            makeSubscription(amount: 550, isActive: false),
        ]
        let expected = subscriptions.filter(\.isActive).reduce(0) { $0 + $1.monthlyEquivalent }
        #expect(WidgetSnapshotUpdater.makeSnapshot(from: subscriptions).monthlyTotalYen == expected)
    }
}
