import Foundation
import SwiftData

@Model
final class Subscription {
    @Attribute(.unique) var id: UUID
    var serviceName: String
    var masterServiceId: String?
    var amount: Int
    var billingCycle: BillingCycle
    var billingDay: Int
    var startedAt: Date
    var category: SubscriptionCategory
    var isActive: Bool
    var memo: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \UsageEvaluation.subscription)
    var evaluations: [UsageEvaluation] = []

    init(
        serviceName: String,
        amount: Int,
        billingCycle: BillingCycle = .monthly,
        billingDay: Int,
        category: SubscriptionCategory = .other,
        masterServiceId: String? = nil
    ) {
        self.id = UUID()
        self.serviceName = serviceName
        self.amount = amount
        self.billingCycle = billingCycle
        self.billingDay = billingDay
        self.startedAt = .now
        self.category = category
        self.masterServiceId = masterServiceId
        self.isActive = true
        self.createdAt = .now
        self.updatedAt = .now
    }
}

extension Subscription {
    /// 月額換算 (年額契約も月割り)
    var monthlyEquivalent: Int {
        switch billingCycle {
        case .monthly:   return amount
        case .yearly:    return amount / 12
        case .quarterly: return amount / 3
        }
    }

    /// 年額換算
    var yearlyEquivalent: Int {
        switch billingCycle {
        case .monthly:   return amount * 12
        case .yearly:    return amount
        case .quarterly: return amount * 4
        }
    }

    /// 直近評価の推奨アクション (nil = 未評価)
    var latestRecommendation: EvaluationResult? {
        evaluations.sorted { $0.evaluatedAt > $1.evaluatedAt }.first?.result
    }

    /// 次回引落日 (startedAt を起点に cycle 加算した対象月の billingDay)
    var nextBillingDate: Date {
        Date.nextBillingDate(cycle: billingCycle, day: billingDay, startedAt: startedAt)
    }
}
