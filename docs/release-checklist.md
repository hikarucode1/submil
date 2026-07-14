# サブミル リリースチェックリスト

App Store 初回リリース (v1.0) までに必要な作業を一枚に集約する。**Linux で完結する実装・文言・設定は
PR 化済み**で、以下は主に **Mac / 各種コンソール操作**が残る項目。各詳細は `docs/setup/*.md` を参照。

凡例: 🖥 Mac/Xcode 必須 ／ 🌐 Web コンソール ／ 🎨 デザイン ／ ✅ 済(実装/PR)

---

## 0. PR マージ順

RootView の `.task` を複数系統が編集するため、順序を守る (交差する系統は 2 つ目を手動解決)。
GitHub の "Codex 静的レビュー" は全 PR「マージブロッカー無し」。

| # | 系統 | PR | 備考 |
| --- | --- | --- | --- |
| 1 | プライバシー/規約 (Web) | submil-content **#1 → #2** | マージ後に GitHub Pages が公開される (後続の URL 疎通確認に必要) |
| 2 | AdMob → ATT | **#80 → #81** | #81 は #80 マージ後に base が main へ。RootView.task を触る |
| 3 | Analytics → Crashlytics | **#82 → #83** | #82 は #80/#81 マージ後、**RootView.task を手動解決** |
| 4 | ストア文言 → fastlane | **#85 → #86** | |
| 5 | 規約(アプリ内) → バージョン表示 | **#84 → #87** | #84 は content 公開後に URL 疎通確認してから |
| 6 | バンドル統合テスト | **#88** | 独立 |

> マージ後の私 (Claude) 側フォローアップ: **#48 合流後、`AdConfig` に `CrashReporter.record` を追加**
> (本番 ID 差し替え漏れを Crashlytics 非致命記録する。現状は TODO コメント残置)。

---

## 1. AdMob / ATT (#45 / #46) — `docs/setup/admob.md`, `att.md`

- [ ] 🖥 SPM で `GoogleMobileAds` (v12+) を追加
- [ ] 🌐 AdMob 管理画面で本番アプリ ID / バナー ユニット ID を発行
- [ ] 🖥 `AdConfig.productionApplicationID` / `productionBannerUnitID` を本番値へ差し替え
- [ ] 🖥 `Info.plist`(ビルド設定)に `GADApplicationIdentifier`(本番アプリ ID)と `SKAdNetworkItems` を追加
- [ ] 🖥 実機で初回起動時に **ATT ダイアログが 1 回だけ**表示されるか確認(active 遷移時)
- [ ] 🖥 実機でバナー表示を確認(iPhone / **iPad で高さクリップされない**こと、Release でテスト広告でないこと)

> `NSUserTrackingUsageDescription` は pbxproj に設定済み ✅。本番 ID がプレースホルダーのままだと
> Release ではクラッシュせず**バナー非表示**にフォールバックする(収益ゼロに気付きにくいので上記チェック必須)。

## 2. Firebase Analytics / Crashlytics (#47 / #48) — `firebase-analytics.md`, `crashlytics.md`

- [ ] 🌐 Firebase プロジェクト作成 + iOS アプリ登録(bundle id `com.hikaru.failuremuseum.submil`)
- [ ] 🖥 `GoogleService-Info.plist` を `submil/` 配下に配置(同期グループで自動同梱)
- [ ] 🖥 SPM で `FirebaseAnalytics` + `FirebaseCrashlytics` を追加
- [ ] 🖥 DebugView(`-FIRDebugEnabled`)で 5 イベント送信を確認
       (subscription_added / evaluation_completed / cancellation_completed / affiliate_clicked / shared)
- [ ] 🖥 Crashlytics: dSYM アップロードの Run Script を Build Phases に追加
- [ ] 🖥 Release の Debug Information Format = `DWARF with dSYM File` を確認
- [ ] 🖥 テストクラッシュ(`CrashReporter.testCrash()`)→ 再起動 → Console にレポート確認

## 3. 法務ページ公開 (#52 / #53) — `submil-content`

- [ ] 🌐 submil-content の #1 / #2 マージ後、GitHub Pages が有効か確認
- [ ] 🌐 `privacy-policy.html` / `terms.html` が **404 でなく表示される**ことをブラウザで確認
      (アプリ内 #84 とストア #51 がこの URL を参照)
- [ ] ✍️ **連絡先メール**(暫定 `hikaruken0126@gmail.com`)と**事業者名表記**(暫定「当方」)を確定
      — privacy/terms 両 HTML と ASC 双方を揃える

## 4. アプリアイコン (#49) 🎨

- [ ] 🎨 全サイズのアイコンを制作(1024pt マスター + 各サイズ)
- [ ] 🖥 `Assets.xcassets/AppIcon` に登録

## 5. スクリーンショット (#50)

- [ ] 🖥 6.7" / 5.5"(必須サイズ)をシミュレータで撮影
- [ ] 🖥 `fastlane/metadata/<locale>/screenshots/` に配置し、`Deliverfile` / `beta` レーンの
      `skip_screenshots` を `false` に変更

## 6. App Store Connect 設定 (#54) 🌐 — `app-store-listing.md`

- [ ] 🌐 App レコード作成(bundle id / SKU / プライマリ言語)
- [ ] 🌐 **サポート URL(必須)** の実ページを用意して設定 ← 未整備。**申請ブロッカー**
      (例: submil-content に `support.html` を追加)
- [ ] 🌐 プライバシーポリシー URL を設定(#52 の Pages URL)
- [ ] 🌐 カテゴリ(主: ファイナンス / 副: ユーティリティ)、年齢制限レーティング
- [ ] 🌐 App のプライバシー(データ収集: 使用状況/診断/識別子 = Firebase/AdMob)を申告
- [ ] 🌐 輸出コンプライアンス(標準暗号のみ = 該当なし想定)

## 7. fastlane / CI (#55) — `fastlane.md`

- [ ] 🌐 App Store Connect API Key 発行 → GitHub Secrets(`ASC_KEY_ID`/`ASC_ISSUER_ID`/`ASC_KEY_CONTENT`)
- [ ] 🌐 証明書用 **private リポ**作成 → Secrets(`MATCH_GIT_URL`/`MATCH_PASSWORD`/`MATCH_GIT_BASIC_AUTHORIZATION`)
- [ ] 🖥 初回 `bundle exec fastlane match appstore`(証明書/プロファイル生成)
- [ ] 🖥 `bundle install` 後に **`Gemfile.lock` をコミット**(CI 再現性。Linux で生成不可のため Mac で)
- [ ] 🖥 `submil` スキームが **Shared** か確認(共有スキームは PR 同梱済み ✅)
- [ ] ⚠️ CI の Xcode: 本プロジェクトは iOS 26.5 / Xcode 26 系。GitHub ホストランナーに対応 Xcode が
      載るまで `beta` のビルドは失敗し得る → **Mac ローカル実行** or **self-hosted ランナー**
      (`upload_metadata` はビルド不要で影響なし)

## 8. TestFlight (#56)

- [ ] 🖥 `bundle exec fastlane beta`(archive → ipa → TestFlight アップロード)
- [ ] 🌐 内部テスターを招待して動作確認
- [ ] 🌐 外部ベータ申請(必要なら)

## 9. テスト / 検証

- [ ] 🖥 `#68` の `ServiceCatalogBundleTests` を含む全テストを Mac / xcodebuild で実行(緑を確認)
- [ ] 🖥 設定タブ: 利用規約 / プライバシーポリシーがアプリ内ブラウザで開く、バージョン表示(#57)

---

## 申請前ゲート (これが揃うまで提出しない)

- [ ] **サポート URL** が実在し ASC に設定済み(未整備 = 実質リジェクト要因)
- [ ] **プライバシーポリシー URL** が公開・疎通済みで ASC に設定済み
- [ ] **本番 AdMob ID**(unitID / applicationID / `GADApplicationIdentifier`)がプレースホルダーでない
- [ ] **`GoogleService-Info.plist`** がバンドルに含まれている
- [ ] **アプリアイコン**(全サイズ)と**スクリーンショット**が登録済み
- [ ] 年齢制限レーティング / カテゴリ / データ プライバシー申告 / 輸出コンプライアンス 完了
- [ ] Release ビルドを実機で一通り動作確認(広告表示 / ATT / 各機能)

## 残 GitHub Issue 対応表

| Issue | 内容 | 状態 |
| --- | --- | --- |
| #45 #46 #47 #48 | マネタイズ | 実装 PR 済 → Mac 設定待ち |
| #51 #52 #53 #55 #57 #68 | 文言/法務/CI/バージョン/テスト | 実装 PR 済 → 上記チェック |
| #49 #50 #54 #56 | アイコン/スクショ/ASC/TestFlight | **本チェックリストで対応** |
| #26 | ホームウィジェット (p3) | 任意・未着手 |
