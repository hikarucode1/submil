import Foundation
import Testing
@testable import submil

/// `ServiceCatalog.loadBundled()` の**バンドル統合テスト** (#68)。
///
/// 既存の `ServiceCatalogTests` は inline JSON / 固定配列のみで、実バンドルの
/// `services.json` を読む経路が未検証だった。本 Suite は実際の同梱リソースを読み、
/// 以下の退行を CI で検知する:
///   1. `services.json` の Copy Bundle Resources 同梱漏れ (漏れると無言で空配列)
///   2. `services.json` の破損 / スキーマ不整合 (`Payload` の decode が全失敗 → 空配列)
///
/// - 前提: submilTests は app をテストホスト (`TEST_HOST`) にしているため、`Bundle.main` は
///   app バンドルを指し、同梱の `services.json` を読める。ホスト設定やリソース同梱が崩れると
///   `loadBundled()` が空を返し、本テストが失敗する (= それが検知したい退行)。
@Suite struct ServiceCatalogBundleTests {

    /// 同梱 `services.json` の現在の登録数。増減時はここも更新する。
    private static let expectedMinimumCount = 30

    @Test func bundledCatalogIsNotEmpty() {
        // 同梱漏れ・decode 全失敗のいずれでも空配列になるため、まずこれで検知する。
        #expect(!ServiceCatalog.loadBundled().isEmpty)
    }

    @Test func bundledCatalogHasExpectedCount() {
        let services = ServiceCatalog.loadBundled()
        // 現状 30 件。将来の追加は許容し、大幅な欠落 (部分 decode 失敗等) を検知する下限で見る。
        #expect(services.count >= Self.expectedMinimumCount)
    }

    @Test func bundledCatalogHasUniqueIDs() {
        let ids = ServiceCatalog.loadBundled().map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func bundledCatalogContainsKnownService() {
        // 実データが正しく decode されていることを、代表的なサービスの存在で確かめる。
        let ids = Set(ServiceCatalog.loadBundled().map(\.id))
        #expect(ids.contains("netflix"))
    }

    @Test func bundledCatalogFieldsAreWellFormed() {
        // 各エントリが空でない id/name と正の金額を持つ (スキーマの健全性)。
        for service in ServiceCatalog.loadBundled() {
            #expect(!service.id.isEmpty)
            #expect(!service.name.isEmpty)
            #expect(service.defaultMonthlyAmount > 0)
        }
    }
}
