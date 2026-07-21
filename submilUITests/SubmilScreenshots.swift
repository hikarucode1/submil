//
//  SubmilScreenshots.swift
//  submilUITests
//
//  App Store 用スクリーンショット (#50) を fastlane snapshot で自動撮影する UITest。
//  各画面へ遷移し snapshot() を呼ぶ。ナビゲーションは存在チェックで守り、
//  一箇所の遷移失敗が全体を巻き込まないようにしている。
//

import XCTest

final class SubmilScreenshots: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        // アプリ側 (DEBUG) の撮影モードを有効化する: 広告/ATT/計測 OFF + デモデータ投入。
        app.launchArguments += ["UITEST_SNAPSHOT"]
        app.launch()

        // 1. ホーム (合計 + 一覧 + 累計節約バナー)
        let home = app.tabBars.buttons["ホーム"]
        XCTAssertTrue(home.waitForExistence(timeout: 20), "ホームタブが表示されない")
        home.tap()
        // 一覧が描画されるまで待つ (デモデータ投入後)。
        _ = app.staticTexts["Netflix"].waitForExistence(timeout: 10)
        snapshot("01-Home")

        // 2. サブスク追加シート
        let addButton = app.navigationBars.buttons["サブスクを追加"]
        if addButton.waitForExistence(timeout: 5) {
            addButton.tap()
            if app.navigationBars["サブスクを追加"].waitForExistence(timeout: 5) {
                snapshot("02-AddSubscription")
            }
            let cancel = app.navigationBars.buttons["キャンセル"]
            if cancel.exists { cancel.tap() }
        }

        // 3. サブスク詳細 (直近の評価結果 + 評価フロー導線)
        let netflixRow = app.staticTexts["Netflix"]
        if netflixRow.waitForExistence(timeout: 5) {
            netflixRow.tap()
            if app.navigationBars["Netflix"].waitForExistence(timeout: 5) {
                snapshot("03-Detail")

                // 4. 「これ要る?」評価フロー — 質問画面 + 5. 評価結果 (解約推奨)
                //    使っていないサブスクに低使用の回答をして「解約を検討しよう」を出す
                //    (本アプリの核心的な訴求。学割/節約タブは "実装予定" のため撮らない)。
                let evaluate = app.buttons["「これ要る?」を評価する"]
                let reevaluate = app.buttons["もう一度評価する"]
                let evalTrigger = evaluate.exists ? evaluate : reevaluate
                if evalTrigger.waitForExistence(timeout: 3) {
                    evalTrigger.tap()

                    // intro の「はじめる」→ 質問1 (最後に使ったのは?)
                    let start = app.buttons["はじめる"]
                    if start.waitForExistence(timeout: 5) {
                        start.tap()
                    }

                    // 質問1が出たら、選択肢が並ぶ状態を 04 として撮る。
                    let q1Choice = app.buttons["それ以上前"]
                    if q1Choice.waitForExistence(timeout: 5) {
                        snapshot("04-Evaluation")
                        q1Choice.tap()                                   // → 質問2
                    }
                    // 質問2 (月に何回?) → 「ほぼ使わない」
                    let q2Choice = app.buttons["ほぼ使わない"]
                    if q2Choice.waitForExistence(timeout: 5) { q2Choice.tap() }
                    // 質問3 (無くなったら困る?) → 「全く困らない」→ 結果へ
                    let q3Choice = app.buttons["全く困らない"]
                    if q3Choice.waitForExistence(timeout: 5) { q3Choice.tap() }

                    // 評価結果 (解約を検討しよう) を 05 として撮る。
                    if app.staticTexts["解約を検討しよう"].waitForExistence(timeout: 5) {
                        snapshot("05-Result")
                    }
                    // シートを閉じる。
                    app.swipeDown(velocity: .fast)
                }
            }
            // ホームへ戻る。
            let back = app.navigationBars.buttons.element(boundBy: 0)
            if back.exists { back.tap() }
        }
    }
}
