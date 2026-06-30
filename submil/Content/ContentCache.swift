import Foundation

/// `URLSession` を抽象化し、テストでネットワークを差し替え可能にする (#35)。
protocol DataFetching: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: DataFetching {}

/// リモート配信される静的コンテンツの種別。`rawValue` がファイル名 (拡張子なし) 兼バンドルリソース名。
enum ContentResource: String, CaseIterable, Sendable {
    case services = "services"
    case studentPlans = "student-plans"
    case cancellationGuides = "cancellation-guides"
}

/// 静的コンテンツ JSON の取得・キャッシュを担う actor (#35)。
///
/// 取得順: **リモート (GitHub Pages) → ディスクキャッシュ (.cachesDirectory) → バンドル同梱**。
/// リモートが取れればキャッシュを更新し、取れなければ最後に取れた内容/同梱内容へフォールバックする。
/// ETag による条件付き取得は #35 のスコープ外 (p3)。
actor ContentCache {
    static let shared = ContentCache()

    /// 配信元 (submil-content の GitHub Pages)。
    static let defaultBaseURL = URL(string: "https://hikarucode1.github.io/submil-content/")!

    private let baseURL: URL
    private let fetcher: DataFetching
    private let bundle: Bundle
    private let fileManager: FileManager
    private let cacheDirectory: URL?
    private var memory: [ContentResource: Data] = [:]

    init(
        baseURL: URL = ContentCache.defaultBaseURL,
        fetcher: DataFetching = URLSession.shared,
        bundle: Bundle = .main,
        fileManager: FileManager = .default,
        cacheDirectory: URL? = nil
    ) {
        self.baseURL = baseURL
        self.fetcher = fetcher
        self.bundle = bundle
        self.fileManager = fileManager
        self.cacheDirectory = cacheDirectory
            ?? fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first?
                .appendingPathComponent("content", isDirectory: true)
    }

    /// 最新のコンテンツ Data を返す。取得順: リモート → ディスクキャッシュ → バンドル。
    /// すべて失敗した場合のみ nil。
    func data(for resource: ContentResource) async -> Data? {
        if let remote = await fetchRemote(resource) {
            memory[resource] = remote
            writeDiskCache(remote, for: resource)
            return remote
        }
        if let cached = memory[resource] ?? readDiskCache(resource) {
            memory[resource] = cached
            return cached
        }
        return bundledData(resource)
    }

    // MARK: - Remote

    private func fetchRemote(_ resource: ContentResource) async -> Data? {
        let url = baseURL.appendingPathComponent("\(resource.rawValue).json")
        guard let (data, response) = try? await fetcher.data(from: url) else { return nil }
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            return nil
        }
        return data
    }

    // MARK: - Disk cache (.cachesDirectory)

    private func cacheFileURL(_ resource: ContentResource) -> URL? {
        cacheDirectory?.appendingPathComponent("\(resource.rawValue).json")
    }

    private func writeDiskCache(_ data: Data, for resource: ContentResource) {
        guard let dir = cacheDirectory, let file = cacheFileURL(resource) else { return }
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        try? data.write(to: file, options: .atomic)
    }

    private func readDiskCache(_ resource: ContentResource) -> Data? {
        guard let file = cacheFileURL(resource) else { return nil }
        return try? Data(contentsOf: file)
    }

    // MARK: - Bundle fallback

    private func bundledData(_ resource: ContentResource) -> Data? {
        guard let url = bundle.url(forResource: resource.rawValue, withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }
}
