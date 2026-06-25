import Foundation

/// バンドル同梱 `cancellation-guides.json` の 1 ガイド (サービス別の解約手順)。
/// MVP はバンドル同梱を使用。GitHub Pages からの動的更新は #35 ContentCache で対応する。
struct CancellationGuide: Identifiable, Codable, Equatable {
    let id: String
    let serviceId: String
    let serviceName: String
    let difficulty: GuideDifficulty
    let estimatedMinutes: Int
    let steps: [CancellationStep]
    /// アプリ内課金 (App Store 経由) の場合の補足。無ければ nil。
    let appStoreNote: String?
    /// 手順を最後に確認した日付 (YYYY-MM-DD)。
    let lastVerified: String
}

/// 解約手順の 1 ステップ。
struct CancellationStep: Identifiable, Codable, Equatable {
    /// 表示順 (1 始まり)。`id` も兼ねる。
    let order: Int
    let text: String

    var id: Int { order }
}
