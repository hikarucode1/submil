import SwiftUI

/// 解約理由の選択 sheet (#37)。
/// 理由を 1 つ選んで「解約を記録する」と、親へ選択した `CancellationReason` を渡す。
struct CancellationReasonSheet: View {
    /// 選択確定時のコールバック。親で解約完了処理 (isActive=false + CancellationLog) を行う。
    let onConfirm: (CancellationReason) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selected: CancellationReason?

    var body: some View {
        NavigationStack {
            List {
                Section("解約した理由は?") {
                    ForEach(CancellationReason.allCases, id: \.self) { reason in
                        Button {
                            selected = reason
                        } label: {
                            HStack {
                                Text(reason.label)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selected == reason {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("解約を記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("記録する") {
                        if let selected {
                            onConfirm(selected)
                        }
                    }
                    .disabled(selected == nil)
                }
            }
        }
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            CancellationReasonSheet { _ in }
                .presentationDetents([.medium])
        }
}
