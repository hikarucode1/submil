import SwiftUI

/// リリースノート (更新履歴) 画面 (#57)。
/// 静的な `ReleaseNote.all` をバージョンごとに表示する。
struct ReleaseNotesView: View {
    var body: some View {
        List {
            ForEach(ReleaseNote.all) { note in
                Section {
                    ForEach(Array(note.highlights.enumerated()), id: \.offset) { _, highlight in
                        Label(highlight, systemImage: "sparkle")
                            .labelStyle(.titleAndIcon)
                    }
                } header: {
                    HStack {
                        Text("バージョン \(note.version)")
                        Spacer()
                        Text(note.date)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("リリースノート")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReleaseNotesView()
    }
}
