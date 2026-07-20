import Foundation

/// 1 バージョン分のリリースノート (#57)。
/// App Store Connect の「このバージョンの新機能」と内容を合わせる。
struct ReleaseNote: Identifiable {
    /// マーケティングバージョン。例: "1.0"。`id` を兼ねる。
    let version: String
    /// リリース日。表示用。
    let date: String
    /// 変更点の箇条書き。
    let highlights: [String]

    var id: String { version }
}

extension ReleaseNote {
    /// 静的なリリースノート一覧。新しいバージョンを先頭に追加していく。
    /// App Store 掲載の release_notes (#51) と整合させること。
    static let all: [ReleaseNote] = [
        ReleaseNote(
            version: "1.0",
            date: "2026-07-14",
            highlights: [
                "サブミルをリリースしました",
                "サブスク一覧と月額・年額の自動合計",
                "「これ要る?」評価フローと解約ガイド",
                "節約額のシェアと学割プランの提案",
            ]
        ),
    ]
}
