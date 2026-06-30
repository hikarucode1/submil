import Foundation
import Testing
@testable import submil

@Suite struct ContentCacheTests {

    /// ネットワークを差し替えるモック。data が nil なら接続失敗を模す。
    private struct MockFetcher: DataFetching {
        var data: Data?
        var statusCode: Int = 200

        func data(from url: URL) async throws -> (Data, URLResponse) {
            guard let data else { throw URLError(.notConnectedToInternet) }
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            return (data, response)
        }
    }

    /// テストごとに独立した一時キャッシュディレクトリ。
    private func tempCacheDir() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("content-cache-tests-\(UUID().uuidString)", isDirectory: true)
    }

    private let remoteJSON = Data(#"{"version":"remote","plans":[]}"#.utf8)

    // MARK: - リモート成功

    @Test func remoteSuccessReturnsRemoteDataAndCaches() async {
        let dir = tempCacheDir()
        let cache = ContentCache(fetcher: MockFetcher(data: remoteJSON), cacheDirectory: dir)

        let data = await cache.data(for: .studentPlans)
        #expect(data == remoteJSON)

        // ディスクキャッシュに書き込まれていること。
        let cachedFile = dir.appendingPathComponent("student-plans.json")
        #expect(FileManager.default.fileExists(atPath: cachedFile.path))
    }

    // MARK: - リモート失敗 → ディスクキャッシュ

    @Test func remoteFailureFallsBackToDiskCache() async throws {
        let dir = tempCacheDir()
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let cachedJSON = Data(#"{"version":"disk","plans":[]}"#.utf8)
        try cachedJSON.write(to: dir.appendingPathComponent("student-plans.json"))

        let cache = ContentCache(fetcher: MockFetcher(data: nil), cacheDirectory: dir)
        let data = await cache.data(for: .studentPlans)
        #expect(data == cachedJSON)
    }

    // MARK: - リモート失敗 + キャッシュなし → バンドル

    @Test func remoteFailureWithoutCacheFallsBackToBundle() async {
        // 空の一時ディレクトリ (キャッシュなし) + 接続失敗 → バンドル同梱の services.json を返す。
        // テストはアプリにホスト (TEST_HOST = submil.app) されるため Bundle.main で解決できる。
        let cache = ContentCache(fetcher: MockFetcher(data: nil), cacheDirectory: tempCacheDir())
        let data = await cache.data(for: .services)

        #expect(data != nil)
        let bundled = ServiceCatalog.loadBundled()
        #expect(!bundled.isEmpty)
        // 返った Data がバンドルの services.json としてデコードできること。
        let services = (try? JSONDecoder().decode(BundledServicesProbe.self, from: data ?? Data()))?.services
        #expect(services?.isEmpty == false)
    }

    // MARK: - 非 2xx → フォールバック

    @Test func non2xxStatusFallsBackToBundle() async {
        let cache = ContentCache(
            fetcher: MockFetcher(data: remoteJSON, statusCode: 404),
            cacheDirectory: tempCacheDir()
        )
        let data = await cache.data(for: .services)
        // 404 はリモート無効扱い。キャッシュなしのためバンドルへフォールバック (remoteJSON ではない)。
        #expect(data != remoteJSON)
        #expect(data != nil)
    }

    // MARK: - カタログ統合 (loadLatest)

    @Test func studentPlanCatalogLoadLatestUsesRemoteThenDecodes() async {
        // リモートに有効な student-plans ペイロードを置くと loadLatest がそれをデコードする。
        let remote = Data(#"""
        {"version":"remote","plans":[
          {"id":"x-student","serviceId":"x","serviceName":"X","regularPriceYen":980,
           "studentPriceYen":480,"annualSavingYen":6000,"affiliateUrl":"https://e.com",
           "affiliateProvider":"direct","displayLabel":"[PR] X 学割","eligibilityNote":"学生","callToAction":"見る"}
        ]}
        """#.utf8)
        let cache = ContentCache(fetcher: MockFetcher(data: remote), cacheDirectory: tempCacheDir())
        let plans = await StudentPlanCatalog.loadLatest(cache: cache)
        #expect(plans.count == 1)
        #expect(plans.first?.id == "x-student")
    }

    @Test func catalogLoadLatestFallsBackToBundleOnGarbageRemote() async {
        // リモートが壊れた JSON でも loadLatest はバンドル同梱へフォールバックする。
        let cache = ContentCache(fetcher: MockFetcher(data: Data("not json".utf8)), cacheDirectory: tempCacheDir())
        let guides = await CancellationGuideCatalog.loadLatest(cache: cache)
        #expect(!guides.isEmpty)
    }
}

/// バンドル services.json のトップレベルを最小デコードする検証用プローブ。
private struct BundledServicesProbe: Decodable {
    struct Service: Decodable { let id: String }
    let services: [Service]
}
