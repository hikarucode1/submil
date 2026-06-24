import Foundation

/// ホーム一覧の並び替え基準 (Issue #23)。String raw で @AppStorage に永続化できる。
enum HomeSortOption: String, CaseIterable, Identifiable {
    case amountDescending
    case category
    case billingDate

    var id: String { rawValue }

    var label: String {
        switch self {
        case .amountDescending: return "金額が高い順"
        case .category:         return "カテゴリ順"
        case .billingDate:      return "支払日が近い順"
        }
    }
}

/// ホーム一覧のフィルタ + ソートを行う純粋ロジック (Issue #23)。
/// @AppStorage 永続化と Menu UI は HomeView (#19) 側で本ロジックを呼んで配線する。
enum SubscriptionListArranger {
    /// `subscriptions` を `category` で絞り込み (nil = 全件)、`sort` で並べ替えて返す。
    /// 同値の場合は serviceName 昇順で安定させる。
    static func arrange(
        _ subscriptions: [Subscription],
        filter category: SubscriptionCategory?,
        sort: HomeSortOption
    ) -> [Subscription] {
        let filtered: [Subscription]
        if let category {
            filtered = subscriptions.filter { $0.category == category }
        } else {
            filtered = subscriptions
        }

        switch sort {
        case .amountDescending:
            return filtered.sorted { lhs, rhs in
                if lhs.monthlyEquivalent != rhs.monthlyEquivalent {
                    return lhs.monthlyEquivalent > rhs.monthlyEquivalent
                }
                return lhs.serviceName < rhs.serviceName
            }
        case .category:
            return filtered.sorted { lhs, rhs in
                if lhs.category.displayName != rhs.category.displayName {
                    return lhs.category.displayName < rhs.category.displayName
                }
                return lhs.serviceName < rhs.serviceName
            }
        case .billingDate:
            return filtered.sorted { lhs, rhs in
                if lhs.nextBillingDate != rhs.nextBillingDate {
                    return lhs.nextBillingDate < rhs.nextBillingDate
                }
                return lhs.serviceName < rhs.serviceName
            }
        }
    }
}
