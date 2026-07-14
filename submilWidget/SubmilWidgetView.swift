import WidgetKit
import SwiftUI

/// ウィジェットの表示 (#26)。Small / Medium に対応。
struct SubmilWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SubmilEntry

    private var amountText: String {
        "¥\(entry.snapshot.monthlyTotalYen.formatted())"
    }

    var body: some View {
        content
            .containerBackground(.fill.tertiary, for: .widget)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .systemMedium:
            medium
        default:
            small
        }
    }

    private var header: some View {
        Label("月額合計", systemImage: "yensign.circle.fill")
            .font(.caption.bold())
            .foregroundStyle(.green)
    }

    private var amount: some View {
        Text(amountText)
            .font(.system(.title, design: .rounded).bold())
            .monospacedDigit()
            .minimumScaleFactor(0.6)
            .lineLimit(1)
    }

    private var countText: some View {
        Text("登録中 \(entry.snapshot.activeCount)件")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            Spacer(minLength: 0)
            amount
            countText
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var medium: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                header
                amount
                countText
            }
            Spacer(minLength: 0)
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 44))
                .foregroundStyle(.green.opacity(0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
