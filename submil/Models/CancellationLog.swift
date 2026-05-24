import Foundation
import SwiftData

@Model
final class CancellationLog {
    @Attribute(.unique) var id: UUID

    var serviceName: String
    var monthlyAmountAtCancellation: Int
    var category: SubscriptionCategory

    var cancelledAt: Date
    var reason: CancellationReason
    var note: String?

    /// 年間節約額 (記念碑的に保持)
    var annualSavingYen: Int { monthlyAmountAtCancellation * 12 }

    init(from subscription: Subscription, reason: CancellationReason, note: String? = nil) {
        self.id = UUID()
        self.serviceName = subscription.serviceName
        self.monthlyAmountAtCancellation = subscription.monthlyEquivalent
        self.category = subscription.category
        self.cancelledAt = .now
        self.reason = reason
        self.note = note
    }
}
