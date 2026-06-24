import Foundation

/// 主要サービスのマスタ (services.json) の読み込みとサジェストを担うカタログ。
///
/// MVP はバンドル同梱の `services.json` を使用。GitHub Pages からの動的更新は M5/M6 で対応。
enum ServiceCatalog {
    /// services.json のトップレベル構造 (`{ "version": ..., "services": [...] }`)。
    private struct Payload: Decodable {
        let version: String
        let services: [MasterService]
    }

    /// バンドルから services.json を読み込む。読めない/壊れている場合は空配列。
    static func loadBundled(bundle: Bundle = .main) -> [MasterService] {
        guard
            let url = bundle.url(forResource: "services", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let payload = try? JSONDecoder().decode(Payload.self, from: data)
        else {
            return []
        }
        return payload.services
    }

    /// 入力文字列にマッチするサービスを返す。前方一致を優先し、その後に部分一致。
    /// query が空 (空白のみ含む) なら空配列。大文字小文字は区別しない。
    static func suggestions(
        matching query: String,
        in services: [MasterService],
        limit: Int = 8
    ) -> [MasterService] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return [] }

        let prefixMatches = services.filter { $0.name.lowercased().hasPrefix(trimmed) }
        let containsMatches = services.filter {
            let name = $0.name.lowercased()
            return !name.hasPrefix(trimmed) && name.contains(trimmed)
        }
        return Array((prefixMatches + containsMatches).prefix(limit))
    }
}
