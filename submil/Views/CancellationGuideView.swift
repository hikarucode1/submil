import SwiftUI
import SwiftData

/// 解約ガイド画面 (#36)。
/// 該当サービスの解約手順をステップカードで表示し、難易度・所要時間を示す。
/// 「解約しました!」から理由選択 sheet (#37) を経て解約完了処理を行う。
struct CancellationGuideView: View {
    let subscription: Subscription

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// バンドルから読み込んだ全ガイド (表示中は不変なので一度だけ読む)。
    @State private var guides: [CancellationGuide] = []
    @State private var showingReasonSheet = false
    /// 理由 sheet で選択され、sheet クローズ後に解約完了処理へ渡す理由。
    @State private var pendingReason: CancellationReason?
    /// 解約完了画面 (#40) に渡すサマリ。非 nil の間 fullScreenCover を表示する。
    @State private var completion: CancellationSummary?

    private var guide: CancellationGuide? {
        CancellationGuideCatalog.guide(forServiceId: subscription.masterServiceId, in: guides)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let guide {
                    summaryHeader(guide)
                    stepsList(guide)
                    if let note = guide.appStoreNote {
                        appStoreNoteCard(note)
                    }
                } else {
                    fallbackCard
                }

                completeButton
            }
            .padding()
        }
        .navigationTitle("解約ガイド")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if guides.isEmpty {
                guides = CancellationGuideCatalog.loadBundled()
            }
        }
        .sheet(isPresented: $showingReasonSheet, onDismiss: confirmPendingCancellation) {
            CancellationReasonSheet { reason in
                // 先に sheet を閉じ、onDismiss で解約処理 → 完了画面へ。
                // (sheet と fullScreenCover の提示が重ならないよう遷移を直列化する)
                pendingReason = reason
                showingReasonSheet = false
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(item: $completion) { summary in
            CancellationCompleteView(serviceName: summary.serviceName, annualSaving: summary.annualSaving) {
                completion = nil
                dismiss()
            }
        }
    }

    // MARK: - Sections

    private func summaryHeader(_ guide: CancellationGuide) -> some View {
        HStack(spacing: 16) {
            badge(
                icon: "gauge.with.dots.needle.33percent",
                title: "難易度",
                value: guide.difficulty.label,
                tint: guide.difficulty.color
            )
            badge(
                icon: "clock",
                title: "所要時間",
                value: "約\(guide.estimatedMinutes)分",
                tint: .blue
            )
        }
    }

    private func badge(icon: String, title: String, value: String, tint: Color) -> some View {
        VStack(spacing: 4) {
            Label(value, systemImage: icon)
                .font(.headline)
                .foregroundStyle(tint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private func stepsList(_ guide: CancellationGuide) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("解約手順")
                .font(.headline)
            ForEach(guide.steps) { step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(step.order)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(width: 26, height: 26)
                        .background(Color.accentColor, in: Circle())
                    Text(step.text)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func appStoreNoteCard(_ note: String) -> some View {
        Label {
            Text(note)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        } icon: {
            Image(systemName: "apple.logo")
        }
        .padding()
        .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private var fallbackCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("このサービスの解約手順はまだ準備中です", systemImage: "info.circle")
                .font(.headline)
            Text("多くのサブスクは「設定 > Apple ID > サブスクリプション」、または各サービスの公式サイトのアカウント画面から解約できます。")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var completeButton: some View {
        Button {
            showingReasonSheet = true
        } label: {
            Label("解約しました!", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 8)
    }

    // MARK: - Actions

    /// 理由 sheet クローズ後に呼ばれる。選択済み理由があれば解約を確定し完了画面を出す。
    private func confirmPendingCancellation() {
        guard let reason = pendingReason else { return }
        pendingReason = nil
        completion = completeCancellation(reason: reason)
    }

    /// 解約完了処理 (#37)。サブスクを非アクティブ化し、記念碑的な CancellationLog を残す。
    /// 完了画面 (#40) 用に節約額サマリを返す。
    private func completeCancellation(reason: CancellationReason) -> CancellationSummary {
        subscription.isActive = false
        subscription.updatedAt = .now
        let log = CancellationLog(from: subscription, reason: reason)
        modelContext.insert(log)
        return CancellationSummary(serviceName: subscription.serviceName, annualSaving: log.annualSavingYen)
    }
}

/// 解約完了画面へ渡す不変サマリ (#40)。fullScreenCover(item:) 用に Identifiable。
private struct CancellationSummary: Identifiable {
    let id = UUID()
    let serviceName: String
    let annualSaving: Int
}

private extension GuideDifficulty {
    /// 難易度に対応する表示色。
    var color: Color {
        switch self {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }
}

#Preview("ガイドあり") {
    NavigationStack {
        CancellationGuideView(
            subscription: Subscription(
                serviceName: "Netflix",
                amount: 1490,
                billingDay: 15,
                category: .video,
                masterServiceId: "netflix"
            )
        )
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}

#Preview("ガイドなし (手入力)") {
    NavigationStack {
        CancellationGuideView(
            subscription: Subscription(
                serviceName: "謎のサブスク",
                amount: 500,
                billingDay: 1,
                category: .other
            )
        )
    }
    .modelContainer(for: Subscription.self, inMemory: true)
}
