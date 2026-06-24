import Foundation
import Testing
@testable import submil

@Suite struct SubscriptionListArrangerTests {

    private func sub(_ name: String, _ amount: Int, cycle: BillingCycle = .monthly, billingDay: Int = 1, category: SubscriptionCategory = .other) -> Subscription {
        Subscription(serviceName: name, amount: amount, billingCycle: cycle, billingDay: billingDay, category: category)
    }

    private var sample: [Subscription] {
        [
            sub("Netflix", 1490, category: .video),       // monthly 1490
            sub("Spotify", 9800, cycle: .yearly, category: .music), // monthly 816
            sub("Cheap", 300, category: .video),          // monthly 300
            sub("Apple Music", 1080, category: .music),   // monthly 1080
        ]
    }

    // MARK: - filter

    @Test func nilFilterKeepsAll() {
        let result = SubscriptionListArranger.arrange(sample, filter: nil, sort: .amountDescending)
        #expect(result.count == 4)
    }

    @Test func categoryFilterKeepsOnlyMatching() {
        let result = SubscriptionListArranger.arrange(sample, filter: .music, sort: .amountDescending)
        #expect(Set(result.map(\.serviceName)) == ["Spotify", "Apple Music"])
        #expect(result.allSatisfy { $0.category == .music })
    }

    @Test func filterWithNoMatchReturnsEmpty() {
        let result = SubscriptionListArranger.arrange(sample, filter: .game, sort: .amountDescending)
        #expect(result.isEmpty)
    }

    // MARK: - sort: amount

    @Test func amountSortIsDescendingByMonthlyEquivalent() {
        let result = SubscriptionListArranger.arrange(sample, filter: nil, sort: .amountDescending)
        // monthly換算: Netflix 1490 > AppleMusic 1080 > Spotify 816 > Cheap 300
        #expect(result.map(\.serviceName) == ["Netflix", "Apple Music", "Spotify", "Cheap"])
    }

    @Test func amountSortTiesBreakByServiceName() {
        let tied = [sub("Bbb", 500), sub("Aaa", 500)]
        let result = SubscriptionListArranger.arrange(tied, filter: nil, sort: .amountDescending)
        #expect(result.map(\.serviceName) == ["Aaa", "Bbb"])
    }

    // MARK: - sort: category

    @Test func categorySortGroupsByCategoryDisplayName() {
        let result = SubscriptionListArranger.arrange(sample, filter: nil, sort: .category)
        let displayNames = result.map(\.category.displayName)
        #expect(displayNames == displayNames.sorted())
    }

    // MARK: - sort: billingDate

    @Test func billingDateSortIsAscending() {
        let subs = [
            sub("A", 100, billingDay: 28),
            sub("B", 100, billingDay: 3),
            sub("C", 100, billingDay: 15),
        ]
        let result = SubscriptionListArranger.arrange(subs, filter: nil, sort: .billingDate)
        let dates = result.map(\.nextBillingDate)
        // 絶対日付に依存せず、結果が nextBillingDate 昇順であることを検証
        #expect(dates == dates.sorted())
    }

    // MARK: - HomeSortOption

    @Test func sortOptionHasStableRawValuesForAppStorage() {
        #expect(HomeSortOption.amountDescending.rawValue == "amountDescending")
        #expect(HomeSortOption.category.rawValue == "category")
        #expect(HomeSortOption.billingDate.rawValue == "billingDate")
        #expect(HomeSortOption.allCases.count == 3)
    }
}
