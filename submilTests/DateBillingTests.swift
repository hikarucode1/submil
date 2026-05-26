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

    @Test func monthlyReturnsSameMonthBillingDay() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 20,
            from: date(2026, 5, 15),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2026)
        #expect(calendar.component(.month, from: result) == 5)
        #expect(calendar.component(.day, from: result) == 20)
    }

    @Test func referenceDayMatchesBillingDayReturnsNextCycle() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 15,
            from: date(2026, 5, 15),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2026)
        #expect(calendar.component(.month, from: result) == 6)
        #expect(calendar.component(.day, from: result) == 15)
    }

    @Test func day31InFebruaryRollsOverToMarch31() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 31,
            from: date(2026, 2, 1),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2026)
        #expect(calendar.component(.month, from: result) == 3)
        #expect(calendar.component(.day, from: result) == 31)
    }

    @Test func quarterlyReturnsNextMatchingDay() {
        let result = Date.nextBillingDate(
            cycle: .quarterly,
            day: 1,
            from: date(2026, 5, 10),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2026)
        #expect(calendar.component(.month, from: result) == 6)
        #expect(calendar.component(.day, from: result) == 1)
    }

    @Test func yearlyAtYearEndRollsToJanuaryNextYear() {
        let result = Date.nextBillingDate(
            cycle: .yearly,
            day: 5,
            from: date(2026, 12, 31),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2027)
        #expect(calendar.component(.month, from: result) == 1)
        #expect(calendar.component(.day, from: result) == 5)
    }

    @Test func referenceBeforeBillingDayInSameMonthReturnsSameMonth() {
        let result = Date.nextBillingDate(
            cycle: .monthly,
            day: 1,
            from: date(2026, 5, 31),
            calendar: calendar
        )
        #expect(calendar.component(.year, from: result) == 2026)
        #expect(calendar.component(.month, from: result) == 6)
        #expect(calendar.component(.day, from: result) == 1)
    }
}
