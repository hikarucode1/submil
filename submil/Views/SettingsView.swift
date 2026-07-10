import SwiftUI

/// 設定タブ (#53 で法務ページへのリンクを実装)。
/// 利用規約・プライバシーポリシーを `SafariView` (アプリ内ブラウザ) で開く。
/// バージョン表示・通知設定等は今後 (#57 ほか) このリストに追加していく。
struct SettingsView: View {
    @State private var activePage: LegalPage?

    var body: some View {
        NavigationStack {
            List {
                Section("このアプリについて") {
                    ForEach(LegalPage.allCases) { page in
                        legalRow(page)
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(item: $activePage) { page in
                SafariView(url: page.url)
                    .ignoresSafeArea()
            }
        }
    }

    private func legalRow(_ page: LegalPage) -> some View {
        Button {
            activePage = page
        } label: {
            HStack {
                Text(page.title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.forward.square")
                    .foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
