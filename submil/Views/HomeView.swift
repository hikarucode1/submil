import SwiftUI
import SwiftData

/// ホーム画面 (M3)。サブスク一覧 + 月額/年額合計 + 累計節約バナーを表示する。
/// - #19 基本構造 / #20 合計集計 / #21 節約バナー / #24 空状態
/// - #22 SubscriptionRow / #23 フィルタ・ソート / #25 詳細遷移 を統合
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var subscriptions: [Subscription]
    @Query private var cancellations: [CancellationLog]

    @AppStorage("home.sort") private var sortRaw = HomeSortOption.amountDescending.rawValue
    @AppStorage("home.filter") private var filterRaw = ""  // "" = すべて

    @State private var showingAdd = false

    private var sort: HomeSortOption {
        HomeSortOption(rawValue: sortRaw) ?? .amountDescending
    }
    private var filterCategory: SubscriptionCategory? {
        filterRaw.isEmpty ? nil : SubscriptionCategory(rawValue: filterRaw)
    }

    /// 集計・一覧の対象はアクティブな (解約していない) サブスクのみ。
    private var activeSubscriptions: [Subscription] {
        subscriptions.filter(\.isActive)
    }
    private var arranged: [Subscription] {
        SubscriptionListArranger.arrange(activeSubscriptions, filter: filterCategory, sort: sort)
    }

    // 合計はフィルタに関わらず全アクティブ分を見出しとして表示する (#20)
    private var monthlyTotal: Int {
        activeSubscriptions.reduce(0) { $0 + $1.monthlyEquivalent }
    }
    private var yearlyTotal: Int {
        activeSubscriptions.reduce(0) { $0 + $1.yearlyEquivalent }
    }
    private var totalAnnualSaving: Int {
        cancellations.reduce(0) { $0 + $1.annualSavingYen }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeSubscriptions.isEmpty {
                    EmptyStateView(onAdd: { showingAdd = true })
                } else {
                    contentList
                }
            }
            .navigationTitle("サブミル")
            .toolbar {
                if !activeSubscriptions.isEmpty {
                    ToolbarItem(placement: .topBarLeading) { sortFilterMenu }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAdd = true } label: {
                        Label("サブスクを追加", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddSubscriptionView()
            }
        }
    }

    // MARK: - List (#19)

    private var contentList: some View {
        List {
            Section {
                SummaryCard(monthlyTotal: monthlyTotal, yearlyTotal: yearlyTotal)
                if totalAnnualSaving > 0 {
                    SavingsBanner(totalAnnualSaving: totalAnnualSaving)
                }
            }
            .listRowSeparator(.hidden)

            Section("登録中 (\(arranged.count))") {
                if arranged.isEmpty {
                    Text("このカテゴリの登録はありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(arranged) { subscription in
                        NavigationLink {
                            SubscriptionDetailView(subscription: subscription)
                        } label: {
                            SubscriptionRow(subscription: subscription)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                delete(subscription)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - フィルタ / ソート Menu (#23)

    private var sortFilterMenu: some View {
        Menu {
            Picker("並び替え", selection: $sortRaw) {
                ForEach(HomeSortOption.allCases) { option in
                    Text(option.label).tag(option.rawValue)
                }
            }
            Picker("カテゴリ", selection: $filterRaw) {
                Text("すべて").tag("")
                ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                    Text("\(category.emoji) \(category.displayName)").tag(category.rawValue)
                }
            }
        } label: {
            Label("並び替え・絞り込み", systemImage: "line.3.horizontal.decrease.circle")
        }
    }

    // MARK: - 削除

    /// スワイプ削除 (#22)。レコード自体を削除する。理由付きの「解約」記録 (CancellationLog) は M5 で追加する。
    private func delete(_ subscription: Subscription) {
        modelContext.delete(subscription)
    }
}

// MARK: - 合計カード (#20)

private struct SummaryCard: View {
    let monthlyTotal: Int
    let yearlyTotal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("毎月のサブスク代")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("¥\(monthlyTotal.formatted()) / 月")
                .font(.largeTitle.bold())
                .monospacedDigit()
            Text("年間 ¥\(yearlyTotal.formatted())")
                .font(.callout)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

// MARK: - 累計節約バナー (#21)

private struct SavingsBanner: View {
    let totalAnnualSaving: Int

    var body: some View {
        HStack {
            Text("🎉")
            Text("累計節約額")
                .font(.subheadline)
            Spacer()
            Text("¥\(totalAnnualSaving.formatted())")
                .font(.headline)
                .monospacedDigit()
        }
        .padding()
        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

// MARK: - 空状態 (#24)

private struct EmptyStateView: View {
    let onAdd: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("まだサブスクがありません", systemImage: "tray")
        } description: {
            Text("最初のサブスクを追加して、毎月いくら払っているか見てみよう")
        } actions: {
            Button {
                onAdd()
            } label: {
                Label("サブスクを追加", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Subscription.self, UsageEvaluation.self, CancellationLog.self], inMemory: true)
}
