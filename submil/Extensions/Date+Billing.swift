import Foundation

extension Date {
    /// referenceDate より厳密に後で、最も近い billingDay を返す。
    /// 月内に該当日がない場合 (例: 2月の31日) は翌月に繰り越す。
    /// 今日が支払日と一致する場合は次サイクルへ進む (`nextDate(after:)` の strictly-after 仕様)。
    ///
    /// cycle は将来の表示用 (毎月 / 3 ヶ月毎 / 年 1 回) のシグネチャ用に受け取るが、
    /// 算出ロジック自体は「次に来る同日」だけで cycle に依らない。
    /// (請求側仕様に従い billingDay のみで「次回引落日」を決める方針 — Issue #7)
    static func nextBillingDate(
        cycle: BillingCycle,
        day: Int,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        _ = cycle
        let components = DateComponents(day: day)
        return calendar.nextDate(
            after: referenceDate,
            matching: components,
            matchingPolicy: .nextTime
        ) ?? referenceDate
    }
}
