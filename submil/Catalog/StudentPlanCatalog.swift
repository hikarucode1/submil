import Foundation

/// 学割プラン (student-plans.json) の読み込みとルックアップを担うカタログ (#41)。
///
/// MVP はバンドル同梱の `student-plans.json` を使用。GitHub Pages からの
/// 動的更新は #35 ContentCache で配信元を差し替える想定 (`ServiceCatalog` と同型)。
enum StudentPlanCatalog {
    /// student-plans.json のトップレベル構造 (`{ "version": ..., "plans": [...] }`)。
    /// `_note` 等の追加キーは無視される。
    private struct Payload: Decodable {
        let version: String
        let plans: [StudentPlan]
    }

    /// バンドルから student-plans.json を読み込む。読めない/壊れている場合は空配列。
    static func loadBundled(bundle: Bundle = .main) -> [StudentPlan] {
        guard
            let url = bundle.url(forResource: "student-plans", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(Payload.self, from: data)
        else {
            return []
        }
        return payload.plans
    }

    /// 最新の学割プランを取得する (#35)。ContentCache 経由でリモート→キャッシュ→バンドルの順に解決し、
    /// デコードに失敗した場合はバンドル同梱へフォールバックする。
    static func loadLatest(cache: ContentCache = .shared) async -> [StudentPlan] {
        guard
            let data = await cache.data(for: .studentPlans),
            let payload = try? JSONDecoder().decode(Payload.self, from: data)
        else {
            return loadBundled()
        }
        return payload.plans
    }

    /// プラン ID (`MasterService.studentPlanId`) で 1 件取得。
    static func plan(forId id: String, in plans: [StudentPlan]) -> StudentPlan? {
        plans.first { $0.id == id }
    }

    /// サービス ID (`Subscription.masterServiceId`) で 1 件取得。
    /// 手入力サブスク (masterServiceId == nil) や学割のないサービスでは nil。
    static func plan(forServiceId serviceId: String?, in plans: [StudentPlan]) -> StudentPlan? {
        guard let serviceId else { return nil }
        return plans.first { $0.serviceId == serviceId }
    }
}
