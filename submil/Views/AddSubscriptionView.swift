import SwiftUI
import SwiftData

/// サブスク追加画面。Form ベースで sheet 表示する (Issue #11)。
/// サービス名サジェスト (#12)、カテゴリ (#13)、金額 (#14)、引落日 (#15)、
/// バリデーション (#16)、SwiftData 保存 (#17) を統合する。
struct AddSubscriptionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var serviceName = ""
    @State private var amountText = ""
    @State private var billingCycle: BillingCycle = .monthly
    @State private var billingDay = Calendar.current.component(.day, from: Date())
    @State private var category: SubscriptionCategory = .other
    @State private var startedAt = Date()
    @State private var memo = ""

    @State private var masterServiceId: String?
    @State private var lastSelectedName: String?
    @State private var catalog: [MasterService] = []

    @State private var alertMessage: String?
    @FocusState private var focusedField: SubscriptionInputField?

    private var amountValue: Int { Int(amountText.filter(\.isNumber)) ?? 0 }

    /// 入力中のサービス名に対するサジェスト。直前に選択したサービス名と一致する間は出さない。
    private var suggestions: [MasterService] {
        guard serviceName != lastSelectedName else { return [] }
        return ServiceCatalog.suggestions(matching: serviceName, in: catalog)
    }

    var body: some View {
        NavigationStack {
            Form {
                serviceSection
                if !suggestions.isEmpty {
                    suggestionSection
                }
                detailSection
                memoSection
            }
            .navigationTitle("サブスクを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isSaveable)
                }
            }
            .task { catalog = ServiceCatalog.loadBundled() }
            .alert("入力エラー", isPresented: alertBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var serviceSection: some View {
        Section("サービス") {
            TextField("サービス名", text: $serviceName)
                .focused($focusedField, equals: .serviceName)
                .submitLabel(.next)
        }
    }

    private var suggestionSection: some View {
        Section("候補") {
            ForEach(suggestions) { service in
                Button { apply(service) } label: {
                    HStack {
                        Text(service.logoEmoji)
                        Text(service.name)
                        Spacer()
                        Text("¥\(service.defaultMonthlyAmount.formatted())")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var detailSection: some View {
        Section("詳細") {
            AmountField(amountText: $amountText, focus: $focusedField)

            Picker("請求サイクル", selection: $billingCycle) {
                ForEach(BillingCycle.allCases, id: \.self) { cycle in
                    Text(cycle.displayName).tag(cycle)
                }
            }

            CategoryPicker(category: $category)

            BillingDayPicker(billingDay: $billingDay)

            DatePicker("利用開始日", selection: $startedAt, displayedComponents: .date)
        }
    }

    private var memoSection: some View {
        Section("メモ (任意)") {
            TextField("例: 家族と共有", text: $memo, axis: .vertical)
                .lineLimit(1...3)
        }
    }

    // MARK: - Logic

    private var isSaveable: Bool {
        SubscriptionInputValidator.isValid(
            serviceName: serviceName, amount: amountValue, billingDay: billingDay
        )
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }

    /// サジェスト選択時に各フィールドへ自動補完 (Issue #12)。
    private func apply(_ service: MasterService) {
        serviceName = service.name
        lastSelectedName = service.name
        amountText = String(service.defaultMonthlyAmount)
        billingCycle = service.billingCycle
        category = service.category
        masterServiceId = service.id
        focusedField = nil
    }

    private func save() {
        let errors = SubscriptionInputValidator.validate(
            serviceName: serviceName, amount: amountValue, billingDay: billingDay
        )
        if let first = errors.first {
            alertMessage = first.message
            focusedField = first.field
            return
        }

        let subscription = Subscription(
            serviceName: serviceName.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountValue,
            billingCycle: billingCycle,
            billingDay: billingDay,
            category: category,
            masterServiceId: masterServiceId
        )
        subscription.startedAt = startedAt
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.memo = trimmedMemo.isEmpty ? nil : trimmedMemo

        modelContext.insert(subscription)
        dismiss()
    }
}

// MARK: - 金額入力 (#14)

/// 数値のみ受付・3桁区切り表示・¥ プレフィックスの金額フィールド。
private struct AmountField: View {
    @Binding var amountText: String
    var focus: FocusState<SubscriptionInputField?>.Binding

    var body: some View {
        HStack {
            Text("¥").foregroundStyle(.secondary)
            TextField("金額 (月額)", text: $amountText)
                .keyboardType(.numberPad)
                .focused(focus, equals: .amount)
                .onChange(of: amountText) { _, newValue in
                    let digits = newValue.filter(\.isNumber)
                    let grouped = (Int(digits)?.formatted(.number.grouping(.automatic))) ?? ""
                    if grouped != amountText {
                        amountText = grouped
                    }
                }
        }
    }
}

// MARK: - カテゴリピッカー (#13)

/// SubscriptionCategory を emoji + 表示名で選択する Picker。
private struct CategoryPicker: View {
    @Binding var category: SubscriptionCategory

    var body: some View {
        Picker("カテゴリ", selection: $category) {
            ForEach(SubscriptionCategory.allCases, id: \.self) { category in
                Text("\(category.emoji) \(category.displayName)").tag(category)
            }
        }
    }
}

// MARK: - 引落日ピッカー (#15)

/// 1〜31 から引落日を選択する Picker。短い月に無い日は月末へクランプされる旨を補足表示。
private struct BillingDayPicker: View {
    @Binding var billingDay: Int

    var body: some View {
        Picker("引落日", selection: $billingDay) {
            ForEach(1...31, id: \.self) { day in
                Text("\(day)日").tag(day)
            }
        }
        if billingDay > 28 {
            Text("短い月に該当日が無い場合は、その月の末日に調整されます (例: 2月→2/28)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AddSubscriptionView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
