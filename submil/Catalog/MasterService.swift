import Foundation

/// バンドル同梱 `services.json` の1サービス (主要30サービスのマスタ)。
/// 追加画面のサジェスト元データ。選択時に defaultMonthlyAmount / category /
/// id (= masterServiceId) を入力フィールドへ自動補完する。
struct MasterService: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let category: SubscriptionCategory
    let defaultMonthlyAmount: Int
    let billingCycle: BillingCycle
    let hasStudentPlan: Bool
    let studentPlanId: String?
    let cancellationGuideId: String?
    let logoEmoji: String
}
