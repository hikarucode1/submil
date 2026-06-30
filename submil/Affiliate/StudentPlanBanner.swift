import SwiftUI

/// 学割提案バナー (#42)。サブスク詳細・評価結果で、学割版があるサービスに表示する。
/// タップで `affiliateUrl` をアプリ内ブラウザ (#43, `SafariView`) で開く。
/// `displayLabel` は `[PR]` 表記を含む (景表法・ステマ規制対応、データ側で担保)。
struct StudentPlanBanner: View {
    let plan: StudentPlan

    @State private var showingSafari = false

    var body: some View {
        Button {
            showingSafari = true
        } label: {
            content
        }
        .buttonStyle(.plain)
        .disabled(plan.url == nil)
        .sheet(isPresented: $showingSafari) {
            if let url = plan.url {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .foregroundStyle(.green)
                // [PR] 表記は AffiliateLinkLabel が PR バッジとして強制表示する (#44)。
                AffiliateLinkLabel(text: plan.displayLabel)
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline) {
                Text("年間 ¥\(plan.annualSavingYen.formatted()) お得")
                    .font(.headline)
                    .foregroundStyle(.green)
                    .monospacedDigit()
                Spacer()
                Text(plan.callToAction)
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
            }

            Text(plan.eligibilityNote)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }
}

#Preview {
    StudentPlanBanner(
        plan: StudentPlan(
            id: "adobe-student",
            serviceId: "adobe-cc",
            serviceName: "Adobe Creative Cloud 学生・教職員版",
            regularPriceYen: 7780,
            studentPriceYen: 2180,
            annualSavingYen: 67_200,
            affiliateUrl: "https://www.adobe.com/jp/creativecloud/buy/students.html",
            affiliateProvider: "direct",
            displayLabel: "[PR] Adobe CC 学生版で年¥67,200お得 💰",
            eligibilityNote: "学生証 / 在籍証明書 / 学生メールでの認証必要。初年度は更にディスカウントの可能性あり",
            callToAction: "学生・教職員版を見る"
        )
    )
    .padding()
}
