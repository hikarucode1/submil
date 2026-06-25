import Foundation
import Testing
@testable import submil

@Suite struct CancellationGuideCatalogTests {

    private func guide(_ id: String, serviceId: String, difficulty: GuideDifficulty = .easy) -> CancellationGuide {
        CancellationGuide(
            id: id,
            serviceId: serviceId,
            serviceName: serviceId.capitalized,
            difficulty: difficulty,
            estimatedMinutes: 2,
            steps: [CancellationStep(order: 1, text: "ログイン")],
            appStoreNote: nil,
            lastVerified: "2026-05-21"
        )
    }

    private var sample: [CancellationGuide] {
        [
            guide("netflix-cancel", serviceId: "netflix"),
            guide("spotify-cancel", serviceId: "spotify", difficulty: .medium),
        ]
    }

    // MARK: - lookup

    @Test func guideByIdFound() {
        let result = CancellationGuideCatalog.guide(forId: "spotify-cancel", in: sample)
        #expect(result?.serviceId == "spotify")
    }

    @Test func guideByIdNotFoundReturnsNil() {
        #expect(CancellationGuideCatalog.guide(forId: "unknown", in: sample) == nil)
    }

    @Test func guideByServiceIdFound() {
        let result = CancellationGuideCatalog.guide(forServiceId: "netflix", in: sample)
        #expect(result?.id == "netflix-cancel")
    }

    @Test func nilServiceIdReturnsNil() {
        // 手入力サブスク (masterServiceId == nil) はガイドなし
        #expect(CancellationGuideCatalog.guide(forServiceId: nil, in: sample) == nil)
    }

    @Test func unknownServiceIdReturnsNil() {
        #expect(CancellationGuideCatalog.guide(forServiceId: "zzz", in: sample) == nil)
    }

    // MARK: - Codable (cancellation-guides.json スキーマ整合)

    @Test func guideDecodesFromCatalogSchema() throws {
        let json = """
        {
          "id": "amazon-prime-cancel",
          "serviceId": "amazon-prime",
          "serviceName": "Amazon Prime",
          "difficulty": "medium",
          "estimatedMinutes": 5,
          "steps": [
            { "order": 1, "text": "amazon.co.jp にログイン" },
            { "order": 2, "text": "プライム会員情報の管理" }
          ],
          "appStoreNote": null,
          "lastVerified": "2026-05-21"
        }
        """
        let decoded = try JSONDecoder().decode(CancellationGuide.self, from: Data(json.utf8))
        #expect(decoded.id == "amazon-prime-cancel")
        #expect(decoded.difficulty == .medium)
        #expect(decoded.estimatedMinutes == 5)
        #expect(decoded.steps.count == 2)
        #expect(decoded.steps.first?.text == "amazon.co.jp にログイン")
        #expect(decoded.appStoreNote == nil)
    }
}
