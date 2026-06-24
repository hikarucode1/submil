import Foundation

/// 追加画面の入力フィールド。エラー時のフォーカス対象 (@FocusState) に使う。
enum SubscriptionInputField: Hashable {
    case serviceName
    case amount
    case billingDay
}

/// サブスク追加時の入力エラー。
enum SubscriptionInputError: Equatable {
    case emptyServiceName
    case nonPositiveAmount
    case billingDayOutOfRange

    /// Alert 表示用メッセージ。
    var message: String {
        switch self {
        case .emptyServiceName:    return "サービス名を入力してください"
        case .nonPositiveAmount:   return "金額は1円以上で入力してください"
        case .billingDayOutOfRange: return "引落日は1〜31の範囲で選択してください"
        }
    }

    /// エラー時にフォーカスするフィールド。
    var field: SubscriptionInputField {
        switch self {
        case .emptyServiceName:    return .serviceName
        case .nonPositiveAmount:   return .amount
        case .billingDayOutOfRange: return .billingDay
        }
    }
}

/// サブスク追加入力のバリデーション。Subscription とは独立した純粋関数として
/// 切り出し、UI から分離してテスト可能にする (Issue #16 / #18)。
enum SubscriptionInputValidator {
    static let billingDayRange = 1...31

    /// 入力を検証し、見つかったエラーをフィールド順 (serviceName → amount → billingDay) で返す。
    /// 空配列なら妥当。先頭エラーの `field` をフォーカス対象にできる。
    static func validate(serviceName: String, amount: Int, billingDay: Int) -> [SubscriptionInputError] {
        var errors: [SubscriptionInputError] = []

        if serviceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyServiceName)
        }
        if amount <= 0 {
            errors.append(.nonPositiveAmount)
        }
        if !billingDayRange.contains(billingDay) {
            errors.append(.billingDayOutOfRange)
        }

        return errors
    }

    /// 妥当な入力かどうか。
    static func isValid(serviceName: String, amount: Int, billingDay: Int) -> Bool {
        validate(serviceName: serviceName, amount: amount, billingDay: billingDay).isEmpty
    }
}
