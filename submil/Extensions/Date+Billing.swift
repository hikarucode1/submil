import Foundation

extension Date {
    /// referenceDate より厳密に後で、最も近い「次回引落日」を返す。
    ///
    /// - `startedAt` の年月を起点に cycle (monthly=1 / quarterly=3 / yearly=12 か月) ずつ進めた対象月の `day` を候補とする。
    /// - 対象月に該当日がない場合 (例: 2 月 31 日) は当月末にクランプ (例: 2/28 or 2/29)。実際のサブスク課金の月末挙動に合わせる。
    /// - referenceDate と一致する候補は採用しない (strictly-after)。
    /// - `day` は 1...31 にクランプ。
    static func nextBillingDate(
        cycle: BillingCycle,
        day: Int,
        startedAt: Date,
        from referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        let clampedDay = max(1, min(31, day))
        let step: Int = {
            switch cycle {
            case .monthly:   return 1
            case .quarterly: return 3
            case .yearly:    return 12
            }
        }()

        let anchorComponents = calendar.dateComponents([.year, .month], from: startedAt)
        guard let anchor = calendar.date(from: anchorComponents) else {
            return referenceDate
        }

        let maxIterations = 1200 / step + 1
        for iteration in 0..<maxIterations {
            guard let targetMonth = calendar.date(
                byAdding: .month, value: iteration * step, to: anchor
            ) else { break }

            let candidate = billingDate(in: targetMonth, day: clampedDay, calendar: calendar)
            if candidate > referenceDate {
                return candidate
            }
        }
        return referenceDate
    }

    /// `targetMonth` の年月で `day` の日付を返す。月内に該当日がなければ当月末にクランプする。
    private static func billingDate(in targetMonth: Date, day: Int, calendar: Calendar) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: targetMonth)
        guard let year = comps.year, let month = comps.month else { return targetMonth }

        if let direct = calendar.date(from: DateComponents(year: year, month: month, day: day)),
           calendar.component(.day, from: direct) == day {
            return direct
        }
        // 該当日が月内に無い場合は当月末日にクランプ (例: 2 月 31 日 → 2/28 or 2/29)
        guard let firstOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let dayRange = calendar.range(of: .day, in: .month, for: firstOfMonth),
              let lastDay = dayRange.last,
              let clamped = calendar.date(from: DateComponents(year: year, month: month, day: lastDay))
        else { return targetMonth }
        return clamped
    }
}
