import Foundation
import Testing
@testable import submil

@Suite struct DateBillingTests {
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return cal
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func assertYMD(_ result: Date, _ year: Int, _ month: Int, _ day: Int) {
        #expect(calendar.component(.year, from: result) == year)
        #expect(calendar.component(.month, from: result) == month)
        #expect(calendar.component(.day, from: result) == day)
    }

    // MARK: - monthly

    @Test func monthlyReturnsSameMonthBillingDay() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 20,
            startedAt: date(2026, 1, 20),
            from: date(2026, 5, 15),
            calendar: calendar
        )
        assertYMD(result, 2026, 5, 20)
    }

    @Test func monthlyReferenceDayMatchesBillingDayReturnsNextCycle() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 15,
            startedAt: date(2026, 1, 15),
            from: date(2026, 5, 15),
            calendar: calendar
        )
        assertYMD(result, 2026, 6, 15)
    }

    @Test func monthlyReferenceBeforeBillingDayInSameMonthReturnsSameMonth() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 1,
            startedAt: date(2026, 1, 1),
            from: date(2026, 5, 31),
            calendar: calendar
        )
        assertYMD(result, 2026, 6, 1)
    }

    // MARK: - quarterly

    @Test func quarterlyAdvancesByThreeMonthsFromStartedAt() {
        // startedAt=2026/2/10 → 2,5,8,11 月の 10 日。from=5/27 → 次は 8/10
        let result = Date.nextBillingDate(
            cycle: .quarterly,
            day: 10,
            startedAt: date(2026, 2, 10),
            from: date(2026, 5, 27),
            calendar: calendar
        )
        assertYMD(result, 2026, 8, 10)
    }

    @Test func quarterlyBeforeFirstCycleReturnsFirstTarget() {
        // startedAt=2026/3/1 → 3,6,9,12 月。from=2026/5/27 → 次は 6/1
        let result = Date.nextBillingDate(
            cycle: .quarterly,
            day: 1,
            startedAt: date(2026, 3, 1),
            from: date(2026, 5, 27),
            calendar: calendar
        )
        assertYMD(result, 2026, 6, 1)
    }

    // MARK: - yearly

    @Test func yearlyReturnsSameMonthOfNextYear() {
        // startedAt=2025/8/15 → 毎年 8/15。from=2026/5/27 → 2026/8/15
        let result = Date.nextBillingDate(
            cycle: .yearly,
            day: 15,
            startedAt: date(2025, 8, 15),
            from: date(2026, 5, 27),
            calendar: calendar
        )
        assertYMD(result, 2026, 8, 15)
    }

    @Test func yearlyAfterAnchorMonthReturnsNextYear() {
        // startedAt=2025/3/5 → 毎年 3/5。from=2026/5/27 → 2027/3/5
        let result = Date.nextBillingDate(
            cycle: .yearly,
            day: 5,
            startedAt: date(2025, 3, 5),
            from: date(2026, 5, 27),
            calendar: calendar
        )
        assertYMD(result, 2027, 3, 5)
    }

    // MARK: - 月末 / うるう年 繰り越し

    @Test func monthlyDay31InFebruaryRollsOverToMarch31() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 31,
            startedAt: date(2026, 1, 31),
            from: date(2026, 2, 1),
            calendar: calendar
        )
        assertYMD(result, 2026, 3, 31)
    }

    @Test func monthlyDay29InLeapYearReturnsFeb29() {
        // 2024 はうるう年 → 2/29 が valid
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 29,
            startedAt: date(2024, 1, 29),
            from: date(2024, 2, 1),
            calendar: calendar
        )
        assertYMD(result, 2024, 2, 29)
    }

    @Test func monthlyDay29InNonLeapYearRollsToMarch29() {
        // 2025 は平年 → 2/29 が無く 3/29 に繰り越し
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 29,
            startedAt: date(2025, 1, 29),
            from: date(2025, 2, 1),
            calendar: calendar
        )
        assertYMD(result, 2025, 3, 29)
    }

    @Test func yearlyDay29StartedOnLeapDayRollsToMarch29InNonLeapYear() {
        // startedAt=2024/2/29 (うるう日)、from=2025/3/1 → 2025/2/29 は無いので 2025/3/29 に繰り越し
        let result = Date.nextBillingDate(
            cycle: .yearly,
            day: 29,
            startedAt: date(2024, 2, 29),
            from: date(2025, 3, 1),
            calendar: calendar
        )
        assertYMD(result, 2025, 3, 29)
    }

    // MARK: - day バリデーション (クランプ)

    @Test func dayBelowOneIsClampedToOne() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 0,
            startedAt: date(2026, 1, 1),
            from: date(2026, 5, 15),
            calendar: calendar
        )
        assertYMD(result, 2026, 6, 1)
    }

    @Test func dayAboveThirtyOneIsClampedToThirtyOne() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 99,
            startedAt: date(2026, 1, 31),
            from: date(2026, 5, 1),
            calendar: calendar
        )
        assertYMD(result, 2026, 5, 31)
    }
}
