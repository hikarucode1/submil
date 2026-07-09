import SwiftUI

/// 節約額シェアの sheet (#38, #39)。
/// カードのプレビューを表示し、ShareSheet で画像 + テキストを共有する。
struct SavingsShareView: View {
    let content: SavingsShareContent

    @Environment(\.dismiss) private var dismiss
    @State private var renderState: RenderState = .rendering
    @State private var showingActivity = false

    /// カード画像のレンダリング状態。`ImageRenderer.uiImage` が nil を返しても
    /// プレビューが固まらないよう、生成中・成功・失敗を明示的に区別する。
    private enum RenderState {
        case rendering
        case ready(UIImage)
        case failed
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                preview
                Text("X・Instagram・LINE などでシェアできます")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    AnalyticsService.log(.shared(cancelledCount: content.cancelledCount))
                    showingActivity = true
                } label: {
                    Label("シェアする", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                // 生成中のみ無効。失敗時はテキストのみで共有できるよう有効化する。
                .disabled(isRendering)
            }
            .padding()
            .navigationTitle("節約をシェア")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
            .sheet(isPresented: $showingActivity) {
                ActivityView(activityItems: activityItems)
            }
            .task {
                if let image = ShareCardRenderer.image(for: content) {
                    renderState = .ready(image)
                } else {
                    renderState = .failed
                }
            }
        }
    }

    private var isRendering: Bool {
        if case .rendering = renderState { return true }
        return false
    }

    @ViewBuilder
    private var preview: some View {
        switch renderState {
        case .rendering:
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 220)
        case let .ready(image):
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8, y: 4)
                .padding(.top, 8)
        case .failed:
            fallbackCard
        }
    }

    /// 画像生成に失敗したときの代替表示。テキストでの共有は引き続き可能。
    private var fallbackCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "scissors")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text(content.headline)
                .font(.title3.bold())
            Text(content.subheadline)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        .padding(.top, 8)
    }

    /// ShareSheet に渡す項目。画像 (生成成功時のみ) + テキスト。
    private var activityItems: [Any] {
        var items: [Any] = []
        if case let .ready(image) = renderState { items.append(image) }
        items.append(content.shareText)
        return items
    }
}

#Preview {
    Color(.systemGroupedBackground)
        .sheet(isPresented: .constant(true)) {
            SavingsShareView(content: SavingsShareContent(totalAnnualSaving: 38400, cancelledCount: 3))
        }
}
