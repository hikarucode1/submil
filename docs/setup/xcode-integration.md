# Xcode 組み込みランブック (リリースチェックリスト 手順2)

AdMob / Firebase Analytics / Crashlytics の **Xcode 上での組み込み**を、依存関係を踏まえた
**実行順**でまとめた実務手順。各項目の詳細は個別 doc へリンクする (本書は順序と横断的な落とし穴に集中)。

> 前提: 先に Web コンソール発行が済んでいること。
> - AdMob 管理画面: 本番 **アプリ ID** (`~` 付き) と **バナー ユニット ID** (`/` 付き)
> - Firebase: プロジェクト作成 → iOS アプリ登録 (bundle id `com.hikaru.failuremuseum.submil`) → `GoogleService-Info.plist` DL
>
> 全コードは `#if canImport(...)` ガード付きのため、パッケージ追加前でもビルドは通る (機能 no-op)。

---

## 実行順の全体像

```
① SPM 追加 (GoogleMobileAds / firebase-ios-sdk)
     └→ ② GoogleService-Info.plist 配置
            └→ ③ Info.plist キー (GADApplicationIdentifier + SKAdNetworkItems)
                   └→ ④ AdConfig 本番 ID 差し替え
                          └→ ⑤ Crashlytics dSYM Run Script + DWARF 確認
                                 └→ ⑥ 検証 (テスト広告→本番 / DebugView / テストクラッシュ)
```

各ステップは前段完了が前提。特に ⑤ は ① の firebase-ios-sdk チェックアウトパスに依存する。

---

## ① Swift Package の追加

Xcode で `submil.xcodeproj` を開き **File > Add Package Dependencies…**。Target は **`submil`**。

| パッケージ | URL | 追加プロダクト | ルール |
| --- | --- | --- | --- |
| Google Mobile Ads | `https://github.com/googleads/swift-package-manager-google-mobile-ads` | `GoogleMobileAds` | Up to Next Major (**v12+**) |
| Firebase iOS SDK | `https://github.com/firebase/firebase-ios-sdk` | `FirebaseAnalytics`, `FirebaseCrashlytics` | Up to Next Major (**v11+**) |

- GoogleMobileAds は **v12+ 前提** (GAD プレフィックスなし API)。v11 以前を解決したら v12+ に上げる。詳細 → [admob.md](admob.md)
- `FirebaseAnalytics` を入れれば `FirebaseCore` (`FirebaseApp`) も解決。`FirebaseCrashlytics` は同じ firebase-ios-sdk から追加。詳細 → [firebase-analytics.md](firebase-analytics.md) / [crashlytics.md](crashlytics.md)

## ② GoogleService-Info.plist の配置

- DL した `GoogleService-Info.plist` を **`submil/` 直下**に置く。
- 本プロジェクトは `PBXFileSystemSynchronizedRootGroup` なので `submil/` 配下に置けば
  自動でターゲットリソースに含まれる (**pbxproj 編集不要**)。
- API キーを含むため、公開方針に応じて `.gitignore` を検討 (Firebase の iOS 用キーはクライアント公開前提)。

## ③ Info.plist キーの追加 (⚠ 最重要の落とし穴)

`submil` アプリターゲットは **`GENERATE_INFOPLIST_FILE = YES`** で、カスタム `Info.plist` を持たない。

- `GADApplicationIdentifier` (単一文字列) は Build Settings の `INFOPLIST_KEY_GADApplicationIdentifier`
  でも入れられるが、
- **`SKAdNetworkItems` は「辞書の配列」なので `INFOPLIST_KEY_` 方式では入れられない。**

### 推奨: カスタム Info.plist を併用 (生成キーとマージ)

**雛形は生成済み → [`Config/submil-Info.plist`](../../Config/submil-Info.plist)** (下記 2 キーのみ。他キーは生成側が自動マージ)。
Xcode 側の作業は **INFOPLIST_FILE を指すだけ**:

1. 雛形は `Config/submil-Info.plist` にある (生成済み)。
2. Target `submil` > Build Settings > **`INFOPLIST_FILE = Config/submil-Info.plist`** を設定。
   `GENERATE_INFOPLIST_FILE = YES` は**そのまま**にする (Xcode がカスタム plist に生成キーをマージ)。

> ⚠️ **`submil/` 配下に置いてはいけない**。`submil/` は同期グループ
> (`PBXFileSystemSynchronizedRootGroup`) で全ファイルが自動的にリソースへコピーされるため、
> Info.plist を置くと「リソースとしてのコピー」と「INFOPLIST_FILE としての生成」が衝突し
> `Multiple commands produce .../submil.app/Info.plist` でビルドが失敗する。
> 同期グループ外 (`Config/`) に置くことで回避している。

雛形に含まれるキー:

| キー | 現在値 | リリース前 |
| --- | --- | --- |
| `GADApplicationIdentifier` | `ca-app-pub-6546223385891550~5066304006` (**本番アプリ ID 設定済み** 2026-07-28) | 差し替え不要。④の `productionApplicationID` と**同じ値を保つ**こと |
| `SKAdNetworkItems` | Google 公式推奨 50 件 (2026-07-28 取得) | 差し替え不要。SDK 更新時に [公式一覧](https://developers.google.com/admob/ios/quick-start#update_your_infoplist) と再同期 |

> `NSUserTrackingUsageDescription` は #46 で pbxproj (`INFOPLIST_KEY_...`) に設定済み → 追加不要。→ [att.md](att.md)

## ④ AdConfig 本番 ID への差し替え

`submil/Ads/AdConfig.swift` の 2 定数を AdMob 発行値へ:

```swift
static let productionBannerUnitID = "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"  // ← /付き ユニットID
static let productionApplicationID = "ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX" // ← ~付き アプリID
```

- ③ の `GADApplicationIdentifier` も**同じ本番アプリ ID** (`~` 付き) に更新する (両者一致必須)。
- DEBUG は `AdConfig.useTestAds == true` で常にテスト広告 → 差し替え後も開発中は安全。
- **差し替え忘れ検知**: Release で `productionBannerUnitID` がプレースホルダ (`0000…`) のままだと
  クラッシュせず**バナー非表示**にフォールバックし、`CrashReporter.record` で Crashlytics 非致命記録。
  「広告が出ない=収益ゼロ」に気付きにくいので ⑥ の実機確認を必ず行う。詳細 → [admob.md](admob.md)

## ⑤ Crashlytics dSYM アップロード — **Run Script 方式は不採用** (この手順は実行しないこと)

> 🚫 **結論: この節の手順は採用していない。実行不要。**
> dSYM の送信は **fastlane `beta` レーンの `upload_symbols_to_crashlytics`** が担当する
> (`fastlane/Fastfile` 参照)。理由は本節末尾の「なぜ放棄したか」を読むこと。
> 以下は「なぜ動かないか」を再検証する人のために記録として残している。

<details>
<summary>不採用となった Run Script 手順 (記録)</summary>

Target `submil` > **Build Phases** > **+** > **New Run Script Phase** を Compile Sources より後 (末尾) に追加。

**Script:** (⚠ Firebase 公式ドキュメントのままでは失敗する。下記の `-gsp` 付きを使うこと)
```sh
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run" -gsp "${SRCROOT}/submil/GoogleService-Info.plist" -p ios
```

**Input Files:**
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
$(SRCROOT)/submil/GoogleService-Info.plist
```

> ⚠️ **公式手順どおりだとビルドが失敗する (実測)**。理由は 2 つ:
> 1. 公式の Input Files `$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)` は、現行 Xcode で
>    `BUILT_PRODUCTS_DIR` が**絶対パス**のため `/…/submil/Users/hikaru/Library/…` という
>    絶対パス同士の連結になり、存在しないパスを指す → `$(SRCROOT)/` を外す。
> 2. Run Script は **sandbox 内で実行**され、Input Files に宣言したファイルしか読めない。
>    `GoogleService-Info.plist` が未宣言だと探索できず
>    `error: Could not get GOOGLE_APP_ID in Google Services file from build environment` で失敗する
>    → `-gsp` で明示 **かつ** Input Files に追加する。

- 「Based on dependency analysis」の**チェックを外す** (毎回実行で確実)。

</details>

### なぜ Run Script を放棄したか (2026-07-29 実測)

上記の `-gsp` + Input Files 宣言で**通常ビルドは通る**ようになったが、**archive (= `fastlane beta`) が失敗する**:

```
error: Unable to load contents of file list: '.../ArchiveIntermediates/SourcePackages/
       checkouts/firebase-ios-sdk/Crashlytics/CrashlyticsInputFiles.xcfilelist'
```

`ENABLE_USER_SCRIPT_SANDBOXING = YES` のため SPM checkout 内のファイルは Input 宣言が必須だが、
そのパスの起点となる `BUILD_DIR` が文脈で変わる:

| 文脈 | `BUILD_DIR` | `SourcePackages` への相対 |
| --- | --- | --- |
| 通常ビルド | `<DerivedData>/Build/Products` | `../../SourcePackages` |
| archive | `<DerivedData>/Build/Intermediates.noindex/ArchiveIntermediates/<target>/BuildProductsPath` | 階層が異なる |

`SourcePackages` 自体は DerivedData 直下の 1 箇所だが、**単一の相対パスで両文脈を満たせない**
(存在しない側を Input に書くとエラーになるため列挙も不可)。サンドボックスを `NO` にすれば回避できるが、
ビルドスクリプトの保護を外すことになる。

→ **fastlane 側で送る方式を採用**。`beta` レーンで `upload_symbols_to_crashlytics` を実行し、
`upload-symbols` のパスは `private_lane :crashlytics_upload_symbols_binary` が
`~/Library/Developer/Xcode/DerivedData/submil-*/SourcePackages/...` を glob して動的解決する
(DerivedData 名にハッシュを含むため固定できない)。サンドボックスは有効なまま維持できる。

- Build Settings > **Debug Information Format** = Release は `DWARF with dSYM File` (本プロジェクトは設定済み ✅)。
  ⚠️ **Debug は `dwarf` で dSYM を生成しない**。Crashlytics の受信確認は必ず **Release ビルド**で行うこと
  (Debug だとレポートは届くが「dSYM 見つからない」でシンボリケートされず可視化されない)。
- 詳細 → [crashlytics.md](crashlytics.md)

## ⑥ 検証 (この順で)

1. **ビルド疎通**: ①〜⑤ 後にビルドが通る。起動時に Firebase 初期化ログ (`Firebase ... started`)。
2. **Analytics DebugView**: Scheme > Run > Arguments に `-FIRDebugEnabled` を追加し、
   `subscription_added` / `evaluation_completed` / `cancellation_completed` / `affiliate_clicked` / `shared`
   の 5 イベントが Firebase Console > DebugView に流れる。→ [firebase-analytics.md](firebase-analytics.md)
3. **テストクラッシュ**: `CrashReporter.testCrash()` (DEBUG 限定) → **デバッガ非接続で実行**→クラッシュ→
   **再起動**→数分後 Crashlytics にレポート。→ [crashlytics.md](crashlytics.md)
4. **広告実機確認**: 実機 Release で ATT ダイアログが**初回起動時 1 回**、バナーが表示される
   (テスト広告でない / iPad で高さクリップされない)。

---

## 完了ゲート (⑥ まで済んで初めて手順3/配信へ)

- [ ] ① SPM: `GoogleMobileAds` + `FirebaseAnalytics` + `FirebaseCrashlytics` 追加済み
- [ ] ② `GoogleService-Info.plist` が `submil/` 配下・ターゲットに含まれる
- [ ] ③ `GADApplicationIdentifier` (本番) + `SKAdNetworkItems` が Info.plist に入っている
- [ ] ④ `AdConfig` の production ID 2 つがプレースホルダ (`0000…`) でない
- [x] ⑤ dSYM 送信は fastlane `beta` に集約 (Run Script は**追加しない**)・Release = `DWARF with dSYM File`
- [ ] ⑥ DebugView 5 イベント / テストクラッシュ受信 / 実機で ATT・バナー確認

## 関連

- 全体像 → [../release-checklist.md](../release-checklist.md) の「手順2」
- 個別詳細 → [admob.md](admob.md) / [firebase-analytics.md](firebase-analytics.md) / [crashlytics.md](crashlytics.md) / [att.md](att.md)
