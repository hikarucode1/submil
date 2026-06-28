import SwiftUI

/// 節約額シェアの sheet (#38, #39)。
/// カードのプレビューを表示し、ShareSheet で画像 + テキストを共有する。
struct SavingsShareView: View {
    let content: SavingsShareContent

    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showingActivity = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                preview
                Text("X・Instagram・LINE などでシェアできます")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showingActivity = true
                } label: {
                    Label("シェアする", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(image == nil)
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
            .task { image = ShareCardRenderer.image(for: content) }
        }
    }

    @ViewBuilder
    private var preview: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 8, y: 4)
                .padding(.top, 8)
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 220)
        }
    }

    /// ShareSheet に渡す項目。画像 (任意) + テキスト。
    private var activityItems: [Any] {
        var items: [Any] = []
        if let image { items.append(image) }
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
