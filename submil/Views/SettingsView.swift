import SwiftUI

/// 設定タブ。「このアプリについて」に法務ページ (#53)・リリースノート/バージョン (#57) を表示する。
/// 利用規約・プライバシーポリシーは `SafariView` (アプリ内ブラウザ) で開く。
/// 通知設定等は今後このリストに追加していく。
struct SettingsView: View {
    @State private var activePage: LegalPage?

    var body: some View {
        NavigationStack {
            List {
                Section("このアプリについて") {
                    ForEach(LegalPage.allCases) { page in
                        legalRow(page)
                    }
                    NavigationLink {
                        ReleaseNotesView()
                    } label: {
                        Text("リリースノート")
                    }
                    versionRow
                }
            }
            .navigationTitle("設定")
            .sheet(item: $activePage) { page in
                SafariView(url: page.url)
                    .ignoresSafeArea()
            }
        }
    }

    private var versionRow: some View {
        HStack {
            Text("バージョン")
            Spacer()
            Text(AppInfo.displayVersion)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
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
