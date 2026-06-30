import Foundation
import Testing
@testable import submil

@Suite struct StudentPlanCatalogTests {

    private func plan(_ id: String, serviceId: String, saving: Int = 6000) -> StudentPlan {
        StudentPlan(
            id: id,
            serviceId: serviceId,
            serviceName: serviceId.capitalized,
            regularPriceYen: 980,
            studentPriceYen: 480,
            annualSavingYen: saving,
            affiliateUrl: "https://example.com/\(serviceId)",
            affiliateProvider: "direct",
            displayLabel: "[PR] \(serviceId) 学割",
            eligibilityNote: "学生のみ",
            callToAction: "詳細を見る"
        )
    }

    private var sample: [StudentPlan] {
        [
            plan("spotify-student", serviceId: "spotify"),
            plan("adobe-student", serviceId: "adobe-cc", saving: 67_200),
        ]
    }

    // MARK: - lookup

    @Test func planByIdFound() {
        let result = StudentPlanCatalog.plan(forId: "adobe-student", in: sample)
        #expect(result?.serviceId == "adobe-cc")
    }

    @Test func planByIdNotFoundReturnsNil() {
        #expect(StudentPlanCatalog.plan(forId: "unknown", in: sample) == nil)
    }

    @Test func planByServiceIdFound() {
        let result = StudentPlanCatalog.plan(forServiceId: "spotify", in: sample)
        #expect(result?.id == "spotify-student")
    }

    @Test func nilServiceIdReturnsNil() {
        // 手入力サブスク (masterServiceId == nil) は学割提案なし
        #expect(StudentPlanCatalog.plan(forServiceId: nil, in: sample) == nil)
    }

    @Test func unknownServiceIdReturnsNil() {
        #expect(StudentPlanCatalog.plan(forServiceId: "zzz", in: sample) == nil)
    }

    // MARK: - Codable (student-plans.json スキーマ整合)

    @Test func planDecodesFromCatalogSchema() throws {
        let json = """
        {
          "id": "github-student",
          "serviceId": "github-copilot",
          "serviceName": "GitHub Student Developer Pack",
          "regularPriceYen": 1500,
          "studentPriceYen": 0,
          "annualSavingYen": 18000,
          "affiliateUrl": "https://education.github.com/pack",
          "affiliateProvider": "direct",
          "displayLabel": "[PR] GitHub Student Pack で無料",
          "eligibilityNote": "学生メール認証",
          "callToAction": "申し込む"
        }
        """
        let decoded = try JSONDecoder().decode(StudentPlan.self, from: Data(json.utf8))
        #expect(decoded.id == "github-student")
        #expect(decoded.serviceId == "github-copilot")
        #expect(decoded.studentPriceYen == 0)
        #expect(decoded.annualSavingYen == 18000)
        #expect(decoded.url != nil)
    }

    // MARK: - バンドル整合 (serviceId ドリフト検知 / 法令・URL 不変条件)

    /// バンドル同梱の全プランの `serviceId` が services.json の id に存在することを保証する。
    /// どちらかがドリフトすると学割版を持つサービスでバナーが黙って出なくなるため不変条件として固定する。
    /// テストはアプリにホスト (TEST_HOST = submil.app) されるため Bundle.main で両 JSON を解決できる。
    @Test func bundledPlanServiceIdsExistInServiceCatalog() {
        let plans = StudentPlanCatalog.loadBundled()
        let services = ServiceCatalog.loadBundled()

        #expect(!plans.isEmpty)
        #expect(!services.isEmpty)

        let serviceIds = Set(services.map(\.id))
        for plan in plans {
            #expect(
                serviceIds.contains(plan.serviceId),
                "学割プラン '\(plan.id)' の serviceId '\(plan.serviceId)' が services.json に存在しません"
            )
        }
    }

    /// `hasStudentPlan == true` のサービスには対応する学割プランが必ず存在することを保証する (逆方向ドリフト検知)。
    @Test func servicesFlaggedWithStudentPlanHaveAPlan() {
        let plans = StudentPlanCatalog.loadBundled()
        let services = ServiceCatalog.loadBundled()
        let planServiceIds = Set(plans.map(\.serviceId))

        for service in services where service.hasStudentPlan {
            #expect(
                planServiceIds.contains(service.id),
                "サービス '\(service.id)' は hasStudentPlan=true ですが student-plans.json にプランがありません"
            )
        }
    }

    /// 全プランが景表法・ステマ規制対応の `[PR]` 表記を含み、かつ affiliateUrl が有効な URL であること。
    @Test func bundledPlansHavePRLabelAndValidURL() {
        let plans = StudentPlanCatalog.loadBundled()
        #expect(!plans.isEmpty)

        for plan in plans {
            #expect(
                plan.displayLabel.contains("[PR]"),
                "プラン '\(plan.id)' の displayLabel に [PR] 表記がありません"
            )
            #expect(plan.url != nil, "プラン '\(plan.id)' の affiliateUrl が不正です: \(plan.affiliateUrl)")
        }
    }
}
