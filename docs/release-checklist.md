# サブミル リリースチェックリスト

App Store 初回リリース (v1.0) までに必要な作業を一枚に集約する。**Linux で完結する実装・文言・設定は
PR 化済み**で、以下は主に **Mac / 各種コンソール操作**が残る項目。各詳細は `docs/setup/*.md` を参照。

凡例: 🖥 Mac/Xcode 必須 ／ 🌐 Web コンソール ／ 🎨 デザイン ／ ✅ 済(実装/PR)

---

## 検証済み現状 (2026-07-28 コード実査 → 同日 SDK 組み込み後に再同期)

実コードと突き合わせた結果。以降の各節チェックボックスはこの結論に合わせて更新済み。
> ⚠️ この節の旧版は本ブランチ初期コミット時点のもの。以降の SDK 組み込みコミット
> (`670dc68` Firebase/AdMob SDK / `a92ca33` Info.plist+本番ID / `c461db5` dSYM Run Script) で
> ★印の「未着手」項目はすべて解消済み。下記は再同期後の状態。

**✅ 完了 (コードで確認)**
- アプリアイコン登録済み (`AppIcon.appiconset`: light/dark/tinted + Contents.json)
- 輸出コンプライアンス `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`
- ATT 説明文 `NSUserTrackingUsageDescription`、共有スキーム `submil.xcscheme`、bundle id、`MARKETING_VERSION 1.0`
- ストア文言 `fastlane/metadata/ja/*` 一式 (support_url / privacy_url 含む)、法務ページ HTTP 200
- **SPM 追加済み**: `GoogleMobileAds` / `FirebaseAnalytics` / `FirebaseCrashlytics` (+ `Package.resolved` コミット済み)
- **`GoogleService-Info.plist` を `submil/` 配下に配置・コミット済み**
- **`Config/submil-Info.plist` に本番 `GADApplicationIdentifier` (`…~5066304006`) + `SKAdNetworkItems` 一式**
- **`AdConfig` の `productionApplicationID` / `productionBannerUnitID` が実値** (プレースホルダ解消済み)
- **Crashlytics dSYM アップロード Run Script を Build Phases に追加済み** (`-gsp` で plist 明示)
- **`submilTests` 全 116 tests / 17 suites 緑** (2026-07-28 xcodebuild 確認、iOS 26.5 / iPhone 17)

**✅ 実機検証 完了 (2026-07-29, iPhone 17e / iOS 26.5.2)**
- ATT ダイアログ 1 回表示 ✅ / バナー統合 ✅ (Test Ad 確認。本番は no fill 待ち)
- Crashlytics クラッシュ受信 + dSYM シンボリケート ✅ / 主要フロー ✅
- 併せて **Release ビルドのブロッカーを 1 件修正** (Crashlytics Run Script のサンドボックス対応)

**❌ 未着手 (＝本当の残作業)** — Web コンソール / 撮影アップロード が中心
- 🌐 Firebase DebugView で 5 イベント送信を確認 / 🌐 ASC レコード (#54) / 🌐 各種 Secrets
- 🌐 撮影済みスクショの ASC 反映 (`upload_screenshots`、ASC API Key 待ち)
- 🖥 iPad でのバナー高さクリップ確認 (任意) / 本番広告の実配信確認 (公開後)

**実行順 (クリティカルパス)**: ~~AdMob/Firebase 発行 → SPM 追加 + plist 配置 + ID 差し替え~~ **(完了)**
→ ~~実機検証~~ **(完了)** → ASC レコード発行(Web) + Secrets → `match` → スクショ upload → `beta` → TestFlight 招待

> 🖥 **手順2 (Xcode 組み込み) の実行ランブック** → [`docs/setup/xcode-integration.md`](setup/xcode-integration.md)
> (SPM→plist→Info.plist→AdConfig→dSYM→検証 を順序付きでまとめた実務手順)

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

> マージ後の私 (Claude) 側フォローアップ: ~~#48 合流後、`AdConfig` に `CrashReporter.record` を追加~~
> → 対応済み ✅ (`AdConfigError.placeholderBannerUnitID` を非致命記録)。

---

## 1. AdMob / ATT (#45 / #46) — `docs/setup/admob.md`, `att.md`

- [x] 🖥 SPM で `GoogleMobileAds` (v12+) を追加
- [x] 🌐 AdMob 管理画面で本番アプリ ID / バナー ユニット ID を発行 (`ca-app-pub-6546223385891550`)
- [x] 🖥 `AdConfig.productionApplicationID` / `productionBannerUnitID` を本番値へ差し替え
- [x] 🖥 `Info.plist`(`Config/submil-Info.plist`)に `GADApplicationIdentifier` と `SKAdNetworkItems` を追加
- [x] 🖥 実機で初回起動時に **ATT ダイアログが 1 回だけ**表示されるか確認(active 遷移時)
      — 2026-07-29 iPhone 17e / iOS 26.5.2 で確認。※端末の「Appからのトラッキング要求を許可」が
      OFF だと iOS が自動拒否しダイアログは出ない(検証時は ON + アプリ再インストールで状態リセット)
- [x] 🖥 実機でバナー表示を確認 — DEBUG(テスト ID)で **Test Ad 表示を確認**、統合・レイアウトとも正常。
      Release(本番 ID)では枠が空だったが、これは**新規ユニットの no fill**(在庫待ち)であり不具合ではない。
      配信開始後に本番広告が出ることを再確認すること。※ iPad での高さクリップ確認は未実施

> `NSUserTrackingUsageDescription` は pbxproj に設定済み ✅。本番 ID がプレースホルダーのままだと
> Release ではクラッシュせず**バナー非表示**にフォールバックする(収益ゼロに気付きにくいので上記チェック必須)。

## 2. Firebase Analytics / Crashlytics (#47 / #48) — `firebase-analytics.md`, `crashlytics.md`

- [x] 🌐 Firebase プロジェクト作成 + iOS アプリ登録(bundle id `com.hikaru.failuremuseum.submil`)
- [x] 🖥 `GoogleService-Info.plist` を `submil/` 配下に配置(同期グループで自動同梱)
- [x] 🖥 SPM で `FirebaseAnalytics` + `FirebaseCrashlytics` を追加
- [ ] 🖥 DebugView(`-FIRDebugEnabled`)で 5 イベント送信を確認
       (subscription_added / evaluation_completed / cancellation_completed / affiliate_clicked / shared)
- [x] 🖥 Crashlytics: dSYM アップロードの Run Script を Build Phases に追加(`-gsp` で plist 明示)
- [x] 🖥 Release の Debug Information Format = `DWARF with dSYM File` を確認
      — `showBuildSettings` で Release=`dwarf-with-dsym` / Debug=`dwarf` を確認 (2026-07-29)
- [x] 🖥 テストクラッシュ → 再起動 → Crashlytics にレポート確認 (2026-07-29 実機)
      — Release ビルドで意図的クラッシュ → 再起動送信 → Firebase Console に
      **`closure #2 in RootView.body.getter` / `RootView.swift:39` / `EXC_BREAKPOINT`** として
      **シンボリケート済みで受信を確認**。dSYM は Run Script が自動アップロード(UUID 一致を確認)。
      ⚠️ 検証は必ず **Release ビルド**で行うこと。Debug は `dwarf` で dSYM を生成せず、
      レポートは届いても「未処理のクラッシュ (dSYM 見つからない)」のまま可視化されない。

## 3. 法務ページ公開 (#52 / #53) — `submil-content`

- [x] 🌐 submil-content の #1 / #2 マージ後、GitHub Pages が有効か確認
- [x] 🌐 `privacy-policy.html` / `terms.html` / `support.html` が **404 でなく表示される**ことを確認
      (3 ページとも HTTP 200 を確認済み 2026-07-20。アプリ内 #84・ストア #51・ASC サポート URL がこれらを参照)
- [ ] ✍️ **連絡先メール**(暫定 `hikaruken0126@gmail.com`)と**事業者名表記**(暫定「当方」)を確定
      — privacy/terms 両 HTML と ASC 双方を揃える

## 4. アプリアイコン (#49) 🎨

- [x] 🎨 アイコン制作(light/dark/tinted, single-size 1024)
- [x] 🖥 `Assets.xcassets/AppIcon` に登録済み (2026-07-28 確認)

## 5. スクリーンショット (#50)

- [x] 🖥 6.9"(iPhone 17 Pro Max = 6.7" 兼用スロット)を `fastlane screenshots` で撮影
      — 2026-07-28 ja 5 枚 (01-Home / 02-AddSubscription / 03-Detail / 04-Evaluation / 05-Result) を
      `fastlane/screenshots/ja/` に出力。撮影 UITest `SubmilScreenshots` が緑で通ることを確認済み。
      ※ 5.5" (iPhone 8 Plus) はオプション枠。撮る場合は iOS 16 系ランタイム追加後に Snapfile へ追記。
- [x] 🌐 撮影済みスクショを ASC へ反映 — **`bundle exec fastlane upload_screenshots`**
      — 2026-07-29 成功。ja 5 枚を 1.0 へアップロード済み。
      (専用レーンが `./fastlane/screenshots` から `skip_screenshots: false` でアップロード。Deliverfile の
      `skip_screenshots(true)` はメタデータ専用レーン `upload_metadata` 用の既定なので変更不要)。
      ※ PNG は `.gitignore` により非コミット(再生成可能な成果物として ASC へ直送する設計)。

> ℹ️ **`upload_metadata` の `No data` について** (2026-07-29)
> deliver が最後に `spaceship .../model.rb:82 No data` を出して exit 1 になるが、
> **ASC 側にはメタデータが正しく反映されている**(概要 / プロモーション用テキスト / キーワード /
> サポート URL を画面で確認済み)。fastlane issue
> [#20538](https://github.com/fastlane/fastlane/issues/20538) と同じ、初回バージョンで出る
> 後処理側のエラーと見られる。**書き込み自体は成功しているので、エラーが出ても ASC を確認すること。**
> なお `upload_screenshots` は同条件でも exit 0 で完走する。

## 6. App Store Connect 設定 (#54) 🌐 — `app-store-listing.md`

- [ ] 🌐 App レコード作成(bundle id / SKU / プライマリ言語)
- [ ] 🌐 **サポート URL(必須)** を設定 — ページは公開済み ✅・`fastlane/metadata/ja/support_url.txt`
      にも設定済み ✅。deliver を使わず手動設定する場合は
      `https://hikarucode1.github.io/submil-content/support.html` を ASC に入力
- [ ] 🌐 プライバシーポリシー URL を設定(#52 の Pages URL)
- [ ] 🌐 カテゴリ(主: ファイナンス / 副: ユーティリティ)、年齢制限レーティング
- [ ] 🌐 App のプライバシー(データ収集: 使用状況/診断/識別子 = Firebase/AdMob)を申告
- [ ] 🌐 輸出コンプライアンス(標準暗号のみ = 該当なし想定)

## 7. fastlane / CI (#55) — `fastlane.md`

- [x] 🌐 App Store Connect API Key 発行 → **ローカル `.env` に設定済み** (2026-07-29, 認証確認済み)
      ※ GitHub Secrets への登録は CI で回す場合に別途必要
- [x] 🌐 証明書用 **private リポ**作成 (`hikarucode1/submil-certs`) → `.env` に `MATCH_GIT_URL`/`MATCH_PASSWORD`
- [x] 🖥 初回 `bundle exec fastlane certificates`(match で証明書/プロファイル生成)
      — app + widget 両 App ID 分を生成し private リポへ保存済み (2026-07-29)
- [x] 🖥 `bundle install` 後に **`Gemfile.lock` をコミット**(CI 再現性。Linux で生成不可のため Mac で)
      — 2026-07-28 Ruby 3.3.12 / bundler 2.5.22 で生成、fastlane 2.237.0 固定 (PR #100)
- [ ] 🖥 `submil` スキームが **Shared** か確認(共有スキームは PR 同梱済み ✅)
- [ ] ⚠️ CI の Xcode: 本プロジェクトは iOS 26.5 / Xcode 26 系。GitHub ホストランナーに対応 Xcode が
      載るまで `beta` のビルドは失敗し得る → **Mac ローカル実行** or **self-hosted ランナー**
      (`upload_metadata` はビルド不要で影響なし)

## 8. TestFlight (#56)

- [x] 🖥 `bundle exec fastlane beta`(archive → ipa → TestFlight アップロード)
      — 2026-07-29 成功。**バージョン 1.0 / ビルド 1 が「提出準備完了」**で TestFlight に表示。
      dSYM も同レーンから Crashlytics へアップロード済み。
- [ ] 🌐 内部テスターを招待して動作確認(TestFlight > 内部テスト でグループ作成 → メール招待)
- [ ] 🌐 外部ベータ申請(必要なら)

## 9. テスト / 検証

- [x] 🖥 `#68` の `ServiceCatalogBundleTests` を含む全テストを Mac / xcodebuild で実行(緑を確認)
      — 2026-07-28 `xcodebuild test -only-testing:submilTests`(iPhone 17 / iOS 26.5)で **116 tests / 17 suites 全緑**
- [x] 🖥 設定タブ: 利用規約 / プライバシーポリシーがアプリ内ブラウザで開く、バージョン表示(#57)
      — 2026-07-29 実機で確認。併せてサブスク追加 / 「これ要る?」評価→結果 / ホーム合計表示も動作確認済み。
      ※ 節約シェア (`SavingsShareView`) は入口の「節約履歴」タブが**実装予定**のため到達不可(仕様どおり)

---

## 申請前ゲート (これが揃うまで提出しない)

- [x] **サポート URL** を ASC に設定済み — `upload_metadata` で反映、ASC 画面で確認済み (2026-07-29)
- [x] **プライバシーポリシー URL** が公開・疎通済みで ASC に設定済み
- [x] **本番 AdMob ID**(unitID / applicationID / `GADApplicationIdentifier`)がプレースホルダーでない
- [x] **`GoogleService-Info.plist`** がバンドルに含まれている
- [x] **アプリアイコン**(全サイズ)と**スクリーンショット**が登録済み
      — アイコンは Assets 登録済み、スクショは ja 5 枚を ASC へアップロード済み (2026-07-29)
- [x] 年齢制限レーティング / カテゴリ / データ プライバシー申告 / 輸出コンプライアンス 完了
      — カテゴリ(ファイナンス/ユーティリティ)は ASC 設定済み、他はユーザーが ASC で入力済み (2026-07-29)
- [x] Release ビルドを実機で一通り動作確認(広告表示 / ATT / 各機能)
      — 2026-07-29 iPhone 17e で実施。ATT ✅ / 広告統合 ✅(本番は no fill 待ち)/ Crashlytics ✅ / 主要フロー ✅

## 残 GitHub Issue 対応表

| Issue | 内容 | 状態 |
| --- | --- | --- |
| #45 #46 #47 #48 | マネタイズ | 実装 PR 済 → Mac 設定待ち |
| #51 #52 #53 #55 #57 #68 | 文言/法務/CI/バージョン/テスト | 実装 PR 済 → 上記チェック |
| #49 #50 #54 #56 | アイコン/スクショ/ASC/TestFlight | **本チェックリストで対応** |
| #26 | ホームウィジェット (p3) | 任意・未着手 |
