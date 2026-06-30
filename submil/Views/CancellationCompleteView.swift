import SwiftUI

/// 解約完了画面 (#40)。
/// 解約を記録した直後の祝祭的なフィードバック。年間節約額を `+¥xx,xxx` のカウントアップ演出で見せ、
/// 「解約してよかった」という前向きな感情を後押しする。
struct CancellationCompleteView: View {
    let serviceName: String
    /// 年間節約額 (= CancellationLog.annualSavingYen)。
    let annualSaving: Int
    let onDone: () -> Void

    /// 表示中の金額。onAppear で 0 → annualSaving へアニメーションさせ、桁を転がす。
    @State private var displayedSaving = 0
    @State private var sealVisible = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
                .symbolEffect(.bounce, value: sealVisible)

            VStack(spacing: 8) {
                Text("解約完了!")
                    .font(.title.bold())
                Text("「\(serviceName)」を解約しました")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            savingsCounter

            Spacer()

            Button(action: onDone) {
                Text("完了")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .onAppear {
            sealVisible = true
            // 画面表示が落ち着いてから金額を転がす (少し遅らせて演出を際立たせる)。
            withAnimation(.easeOut(duration: 0.9).delay(0.35)) {
                displayedSaving = annualSaving
            }
        }
    }

    private var savingsCounter: some View {
        VStack(spacing: 4) {
            Text("年間節約額")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("+¥\(displayedSaving.formatted())")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.green)
                .contentTransition(.numericText(value: Double(displayedSaving)))
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.green.opacity(0.12))
        )
    }
}

#Preview {
    CancellationCompleteView(
        serviceName: "Netflix",
        annualSaving: 17_880,
        onDone: {}
    )
}
