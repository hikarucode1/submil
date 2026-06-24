import Foundation
import Testing
@testable import submil

@Suite struct ServiceCatalogTests {

    private func service(_ id: String, _ name: String, _ category: SubscriptionCategory = .other, amount: Int = 1000) -> MasterService {
        MasterService(
            id: id,
            name: name,
            category: category,
            defaultMonthlyAmount: amount,
            billingCycle: .monthly,
            hasStudentPlan: false,
            studentPlanId: nil,
            cancellationGuideId: nil,
            logoEmoji: "📦"
        )
    }

    private var sample: [MasterService] {
        [
            service("netflix", "Netflix", .video, amount: 1490),
            service("amazon-prime", "Amazon Prime", .video, amount: 600),
            service("spotify", "Spotify", .music, amount: 980),
            service("apple-music", "Apple Music", .music, amount: 1080),
            service("nintendo-online", "Nintendo Switch Online", .game, amount: 306),
        ]
    }

    // MARK: - suggestions

    @Test func emptyQueryReturnsNothing() {
        #expect(ServiceCatalog.suggestions(matching: "", in: sample).isEmpty)
        #expect(ServiceCatalog.suggestions(matching: "   ", in: sample).isEmpty)
    }

    @Test func prefixMatchIsCaseInsensitive() {
        let result = ServiceCatalog.suggestions(matching: "net", in: sample)
        #expect(result.map(\.id) == ["netflix"])
    }

    @Test func uppercaseQueryStillMatches() {
        let result = ServiceCatalog.suggestions(matching: "SPOTIFY", in: sample)
        #expect(result.map(\.id) == ["spotify"])
    }

    @Test func prefixMatchesRankAboveContainsMatches() {
        // "apple" は "Apple Music" を前方一致。"a" は複数を前方一致する
        let result = ServiceCatalog.suggestions(matching: "a", in: sample)
        // 前方一致: Amazon Prime, Apple Music (出現順) → contains 無し
        #expect(result.map(\.id) == ["amazon-prime", "apple-music"])
    }

    @Test func containsMatchIsFoundWhenNoPrefix() {
        // "music" は前方一致なし、Apple Music に部分一致
        let result = ServiceCatalog.suggestions(matching: "music", in: sample)
        #expect(result.map(\.id) == ["apple-music"])
    }

    @Test func limitIsRespected() {
        let many = (0..<20).map { service("svc-\($0)", "Service \($0)") }
        let result = ServiceCatalog.suggestions(matching: "service", in: many, limit: 5)
        #expect(result.count == 5)
    }

    @Test func noMatchReturnsEmpty() {
        #expect(ServiceCatalog.suggestions(matching: "zzz", in: sample).isEmpty)
    }

    // MARK: - Codable (services.json スキーマ整合)

    @Test func masterServiceDecodesFromCatalogSchema() throws {
        let json = """
        {
          "id": "amazon-prime",
          "name": "Amazon Prime",
          "category": "video",
          "defaultMonthlyAmount": 600,
          "billingCycle": "monthly",
          "hasStudentPlan": true,
          "studentPlanId": "amazon-prime-student",
          "cancellationGuideId": "amazon-prime-cancel",
          "logoEmoji": "📦"
        }
        """
        let decoded = try JSONDecoder().decode(MasterService.self, from: Data(json.utf8))
        #expect(decoded.id == "amazon-prime")
        #expect(decoded.category == .video)
        #expect(decoded.billingCycle == .monthly)
        #expect(decoded.defaultMonthlyAmount == 600)
        #expect(decoded.hasStudentPlan == true)
        #expect(decoded.studentPlanId == "amazon-prime-student")
    }

    @Test func nullableFieldsDecodeToNil() throws {
        let json = """
        {
          "id": "netflix",
          "name": "Netflix",
          "category": "video",
          "defaultMonthlyAmount": 1490,
          "billingCycle": "monthly",
          "hasStudentPlan": false,
          "studentPlanId": null,
          "cancellationGuideId": "netflix-cancel",
          "logoEmoji": "📺"
        }
        """
        let decoded = try JSONDecoder().decode(MasterService.self, from: Data(json.utf8))
        #expect(decoded.studentPlanId == nil)
    }
}
