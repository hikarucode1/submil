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

1. `submil/Info.plist` を新規作成し、下記 2 キーだけを記述 (他キーは生成側が自動マージ)。
2. Target `submil` > Build Settings > **`INFOPLIST_FILE = submil/Info.plist`** を設定。
   `GENERATE_INFOPLIST_FILE = YES` は**そのまま**にする (Xcode がカスタム plist に生成キーをマージ)。

記述するキー:

| キー | 値 |
| --- | --- |
| `GADApplicationIdentifier` | 開発中: `ca-app-pub-3940256099942544~1458002511` (テスト用) / 本番: AdMob 発行値 |
| `SKAdNetworkItems` | Google 提供の SKAdNetwork ID 一覧を辞書配列で。→ https://developers.google.com/admob/ios/quick-start#update_your_infoplist |

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

## ⑤ Crashlytics dSYM アップロード Run Script

Target `submil` > **Build Phases** > **+** > **New Run Script Phase** を Compile Sources より後 (末尾) に追加。

**Script:**
```sh
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
```

**Input Files:**
```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

- 「Based on dependency analysis」の**チェックを外す** (毎回実行で確実)。
- Build Settings > **Debug Information Format** = Release は `DWARF with dSYM File` (Xcode デフォルト) を確認。
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
- [ ] ⑤ dSYM Run Script 追加済み・Release = `DWARF with dSYM File`
- [ ] ⑥ DebugView 5 イベント / テストクラッシュ受信 / 実機で ATT・バナー確認

## 関連

- 全体像 → [../release-checklist.md](../release-checklist.md) の「手順2」
- 個別詳細 → [admob.md](admob.md) / [firebase-analytics.md](firebase-analytics.md) / [crashlytics.md](crashlytics.md) / [att.md](att.md)
