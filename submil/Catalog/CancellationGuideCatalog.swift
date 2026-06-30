import Foundation

/// サービス別の解約手順 (cancellation-guides.json) の読み込みとルックアップを担うカタログ。
///
/// MVP はバンドル同梱の `cancellation-guides.json` を使用。GitHub Pages からの
/// 動的更新は #35 ContentCache で配信元を差し替える想定 (`ServiceCatalog` と同型)。
enum CancellationGuideCatalog {
    /// cancellation-guides.json のトップレベル構造 (`{ "version": ..., "guides": [...] }`)。
    private struct Payload: Decodable {
        let version: String
        let guides: [CancellationGuide]
    }

    /// バンドルから cancellation-guides.json を読み込む。読めない/壊れている場合は空配列。
    static func loadBundled(bundle: Bundle = .main) -> [CancellationGuide] {
        guard
            let url = bundle.url(forResource: "cancellation-guides", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(Payload.self, from: data)
        else {
            return []
        }
        return payload.guides
    }

    /// 最新のガイドを取得する (#35)。ContentCache 経由でリモート→キャッシュ→バンドルの順に解決し、
    /// デコードに失敗した場合はバンドル同梱へフォールバックする。
    static func loadLatest(cache: ContentCache = .shared) async -> [CancellationGuide] {
        guard
            let data = await cache.data(for: .cancellationGuides),
            let payload = try? JSONDecoder().decode(Payload.self, from: data)
        else {
            return loadBundled()
        }
        return payload.guides
    }

    /// ガイド ID (`MasterService.cancellationGuideId`) で 1 件取得。
    static func guide(forId id: String, in guides: [CancellationGuide]) -> CancellationGuide? {
        guides.first { $0.id == id }
    }

    /// サービス ID (`Subscription.masterServiceId`) で 1 件取得。
    /// 手入力サブスク (masterServiceId == nil) や未整備サービスでは nil。
    static func guide(forServiceId serviceId: String?, in guides: [CancellationGuide]) -> CancellationGuide? {
        guard let serviceId else { return nil }
        return guides.first { $0.serviceId == serviceId }
    }
}
