import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var didStartAds = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("ホーム", systemImage: "house.fill") }

            StudentPlansTab()
                .tabItem { Label("学割", systemImage: "graduationcap.fill") }

            SavingsTab()
                .tabItem { Label("節約", systemImage: "yensign.circle.fill") }

            SettingsView()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
        }
        .task {
            #if DEBUG
            // スクリーンショット撮影 (#50) 時は計測/広告なしで撮る。専用のデモデータを投入する。
            if SnapshotSupport.isActive {
                SnapshotSupport.prepareUIIfNeeded()
                SnapshotSupport.seed(into: modelContext)
                return
            }
            #endif
            FirebaseStarter.configureIfNeeded()
            #if DEBUG
            SampleData.seed(into: modelContext)
            #endif
        }
        .onChange(of: scenePhase, initial: true) { _, newPhase in
            #if DEBUG
            // 撮影モードでは ATT ダイアログも AdMob 初期化も行わない (画面を汚さない)。
            if SnapshotSupport.isActive { return }
            #endif
            // ATT ダイアログはアプリが active の時のみ表示される。
            // 初回 active への遷移時に一度だけ ATT → AdMob 初期化を行う。
            guard newPhase == .active, !didStartAds else { return }
            didStartAds = true
            Task { await AdMobStarter.startAfterTrackingAuthorization() }
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

#Preview {
    RootView()
}
