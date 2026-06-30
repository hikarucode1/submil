import SwiftUI

/// 広告 (PR) であることを示すバッジ (#44)。景表法・ステマ規制対応。
/// 「広告と明瞭に認識できる」開示要件を満たすため、システム反転色
/// (前景 = 背景色 / 背景 = primary) でライト/ダーク両モードとも高コントラストを担保する。
struct PRBadge: View {
    var body: some View {
        Text("PR")
            .font(.caption.bold())
            .foregroundStyle(Color(.systemBackground))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(Color.primary, in: Capsule())
            .accessibilityLabel("広告")
    }
}

/// アフィリエイトリンクのラベル (#44)。
/// **必ず PR バッジを伴って表示する**ことを型で強制する共通コンポーネント。
/// アフィリリンク表示は raw な `Text` ではなく必ずこれを通すことで、[PR] 表記漏れを防ぐ。
/// データ側の "[PR]" 接頭辞はバッジと重複するため表示時に取り除く。
struct AffiliateLinkLabel: View {
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            PRBadge()
            Text(Self.stripped(text))
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// 先頭の "[PR]" マーカー (全角/小文字含む) を取り除く。バッジで表示するため重複を避ける。
    /// マーカーが無ければそのまま返す。
    static func stripped(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        let markers = ["[PR]", "[pr]", "［PR］", "【PR】"]
        for marker in markers where trimmed.hasPrefix(marker) {
            return String(trimmed.dropFirst(marker.count)).trimmingCharacters(in: .whitespaces)
        }
        return trimmed
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        AffiliateLinkLabel(text: "[PR] Adobe CC 学生版で年¥67,200お得 💰")
        AffiliateLinkLabel(text: "Spotify 学割で月¥500お得")
        PRBadge()
    }
    .padding()
}
