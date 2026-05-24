import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            StudentPlansTab()
                .tabItem { Label("学割", systemImage: "graduationcap.fill") }

            SavingsTab()
                .tabItem { Label("節約", systemImage: "yensign.circle.fill") }

            SettingsTab()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
    }
}

private struct HomeTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "ホーム",
                systemImage: "list.bullet.rectangle",
                description: Text("サブスク一覧と月額合計を表示します (実装予定)")
            )
            .navigationTitle("サブミル")
        }
    }
}

private struct StudentPlansTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "学割プラン",
                systemImage: "graduationcap",
                description: Text("学割で安くなるサービスを提案します (実装予定)")
            )
            .navigationTitle("学割")
        }
    }
}

private struct SavingsTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "節約履歴",
                systemImage: "chart.line.uptrend.xyaxis",
                description: Text("解約済みサブスクと累計節約額 (実装予定)")
            )
            .navigationTitle("節約")
        }
    }
}

private struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "設定",
                systemImage: "gearshape",
                description: Text("通知設定・アカウント・このアプリについて (実装予定)")
            )
            .navigationTitle("設定")
        }
    }
}

#Preview {
    RootView()
}
