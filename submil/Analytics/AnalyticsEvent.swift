import Foundation

/// アプリの主要イベント (#47)。イベント名・パラメータを一箇所に集約し、
/// 送信箇所 (View) は `AnalyticsService.log(_:)` に enum を渡すだけにする。
///
/// - イベント名は Firebase の命名規則 (英小文字 + アンダースコア、予約語回避) に沿う。
/// - パラメータ値は文字列/数値のみ (Firebase の許容型)。列挙は rawValue を渡す。
enum AnalyticsEvent {
    /// サブスク新規登録 (#11 追加フロー)。
    case subscriptionAdded(category: String, billingCycle: String)
    /// 「これ要る?」評価の完了 (#27–#33)。`result` は EvaluationResult.rawValue。
    case evaluationCompleted(result: String)
    /// 解約完了 (#37)。節約額を添える。
    case cancellationCompleted(annualSavingYen: Int)
    /// 学割アフィリンクのタップ (#42, #43)。
    case affiliateClicked(serviceId: String, provider: String)
    /// 節約額シェアの実行 (#38, #39)。
    case shared(cancelledCount: Int)

    /// Firebase に送るイベント名。
    var name: String {
        switch self {
        case .subscriptionAdded:    return "subscription_added"
        case .evaluationCompleted:  return "evaluation_completed"
        case .cancellationCompleted: return "cancellation_completed"
        case .affiliateClicked:     return "affiliate_clicked"
        case .shared:               return "shared"
        }
    }

    /// Firebase に送るパラメータ。
    var parameters: [String: Any] {
        switch self {
        case let .subscriptionAdded(category, billingCycle):
            return ["category": category, "billing_cycle": billingCycle]
        case let .evaluationCompleted(result):
            return ["result": result]
        case let .cancellationCompleted(annualSavingYen):
            return ["annual_saving_yen": annualSavingYen]
        case let .affiliateClicked(serviceId, provider):
            return ["service_id": serviceId, "provider": provider]
        case let .shared(cancelledCount):
            return ["cancelled_count": cancelledCount]
        }
    }
}
