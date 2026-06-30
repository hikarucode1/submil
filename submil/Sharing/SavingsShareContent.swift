import Foundation

/// 節約額シェアの表示テキストを組み立てる純粋な値型 (#38, #39)。
/// SwiftUI / UIKit 非依存に保ち、Unit テスト可能にする。
struct SavingsShareContent: Equatable {
    /// 累計の年間節約額 (円)。CancellationLog.annualSavingYen の合計。
    let totalAnnualSaving: Int
    /// 解約したサブスクの件数。
    let cancelledCount: Int

    init(totalAnnualSaving: Int, cancelledCount: Int) {
        self.totalAnnualSaving = max(0, totalAnnualSaving)
        self.cancelledCount = max(0, cancelledCount)
    }

    /// カード中央の金額表記。例: "¥12,000"
    var amountText: String {
        "¥\(totalAnnualSaving.formatted())"
    }

    /// カードの見出し。例: "年間 ¥12,000 節約!"
    var headline: String {
        "年間 \(amountText) 節約!"
    }

    /// カードのサブ見出し。解約件数を添える。0 件のときは件数を出さない。
    var subheadline: String {
        cancelledCount > 0 ? "\(cancelledCount)件のサブスクを見直しました" : "サブスクを見直しました"
    }

    /// ShareSheet に渡す本文テキスト。画像とあわせて共有される。
    var shareText: String {
        """
        サブミルで年間\(amountText)節約しました！✂️
        あなたのサブスク、チャント見てる?
        #サブミル \(AppLink.appStoreURL.absoluteString)
        """
    }
}
