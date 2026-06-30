import Foundation

/// バンドル同梱 `student-plans.json` の 1 学割プラン (#41)。
/// 対応する `MasterService`（= `serviceId`）にリンクし、詳細・評価結果画面で学割提案バナーを出す。
/// MVP はバンドル同梱を使用。GitHub Pages からの動的更新は #35 ContentCache で配信元を差し替える想定。
struct StudentPlan: Identifiable, Codable, Equatable {
    let id: String
    /// 対応するサービスの ID (= `MasterService.id` / `Subscription.masterServiceId`)。
    let serviceId: String
    let serviceName: String
    let regularPriceYen: Int
    let studentPriceYen: Int
    /// 通常版との年間差額 (円)。バナーの訴求に使う。
    let annualSavingYen: Int
    /// アフィリエイト遷移先 (#43 で SFSafariViewController で開く)。
    let affiliateUrl: String
    let affiliateProvider: String
    /// バナー見出し。景表法・ステマ規制対応のため必ず `[PR]` 表記を含む (データ側で担保)。
    let displayLabel: String
    let eligibilityNote: String
    let callToAction: String

    /// `affiliateUrl` を URL 化したもの。不正な文字列なら nil。
    var url: URL? { URL(string: affiliateUrl) }
}
