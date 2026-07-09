# Firebase Crashlytics セットアップ (#48)

コード側 (`submil/Crash/CrashReporter.swift`, ContentCache のパンくず) は実装済み。
Crashlytics は `FirebaseApp.configure()` (#47) 後に自動で有効化されるため、初期化コードは不要。
以下は **Mac / Xcode 上でのみ実施できる手動手順**。全コードは
`#if canImport(FirebaseCrashlytics)` ガード付きで、パッケージ追加前でもビルドは通る (no-op)。

> 前提: #47 Firebase Analytics のセットアップ (`GoogleService-Info.plist` 配置 +
> `firebase-ios-sdk` の SPM 追加) が済んでいること。`docs/setup/firebase-analytics.md` 参照。

## 1. Swift Package プロダクトの追加

#47 で追加済みの `firebase-ios-sdk` パッケージから、Target `submil` に以下を追加:

- `FirebaseCrashlytics`

> Firebase Console > Crashlytics で対象アプリの Crashlytics を「有効化」しておく
> (初回クラッシュ受信で完了状態になる)。

## 2. dSYM 自動アップロードの Run Script 追加

Xcode で Target `submil` > **Build Phases** > **+** > **New Run Script Phase** を追加し、
Compile Sources より後 (末尾) に配置する。

**Script:**

```sh
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
```

**Input Files** (▸ Input Files に追加):

```
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${TARGET_NAME}
$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)
```

- Run Script は「Based on dependency analysis」のチェックを**外す**と毎回実行され確実。
- SPM の checkout パスが解決できない場合は、`run` スクリプトの絶対パスを
  Xcode の DerivedData 配下 (`.../SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run`)
  で確認する。

## 3. dSYM 生成の確認

Crashlytics はシンボル化に dSYM が必要。以下を確認:

- Target > Build Settings > **Debug Information Format**
  - **Release**: `DWARF with dSYM File` (Xcode デフォルト)。
  - Debug は `DWARF` のままで可 (テストクラッシュ時は下記 4 の手順で確認)。

## 4. テストクラッシュで動作確認

1. `CrashReporter.testCrash()` を一時的にどこかから呼ぶ (例: DEBUG のボタン)。
   `testCrash()` は `#if DEBUG` 限定で `fatalError` を起こす。
2. アプリを **Xcode デタッチ状態** (デバッガを外す) で実行しクラッシュさせる。
   → デバッガ接続中は Crashlytics がクラッシュを捕捉できないことがある。
3. アプリを **再起動** する。起動時に前回のクラッシュレポートが送信される。
4. 数分後、Firebase Console > Crashlytics にレポートが表示されることを確認。

- 非致命エラーの確認: `CrashReporter.record(error)` を呼ぶと Crashlytics の
  「クラッシュ以外」に集計される (アプリは継続)。ContentCache は全ソース失敗時に
  `CrashReporter.log(...)` のパンくずを残す。

## API (`submil/Crash/CrashReporter.swift`)

| メソッド | 用途 |
| --- | --- |
| `log(_:)` | パンくず (直前の状況)。クラッシュレポートに時系列添付 |
| `record(_:)` | 非致命エラーの記録 (アプリ継続) |
| `setCustomValue(_:forKey:)` | 診断用カスタムキー |
| `testCrash()` | 動作確認用の意図的クラッシュ (DEBUG のみ) |

## 関連

- #47 Firebase Analytics: 初期化 (`FirebaseStarter`) と `GoogleService-Info.plist` を共有。
- コード: `submil/Crash/CrashReporter.swift`
