# Firebase Analytics セットアップ (#47)

コード側 (`submil/Analytics/`, 各 View のイベント送信, `RootView` の初期化) は実装済み。
以下は **Mac / Xcode 上でのみ実施できる手動手順**。全コードは
`#if canImport(FirebaseAnalytics)` / `#if canImport(FirebaseCore)` ガード付きのため、
パッケージ追加前でもビルドは通る (計測は no-op)。

## 1. Firebase プロジェクト作成 + アプリ登録

1. [Firebase Console](https://console.firebase.google.com/) でプロジェクト作成。
2. iOS アプリを追加。**バンドル ID = `com.hikaru.failuremuseum.submil`**。
3. `GoogleService-Info.plist` をダウンロード。

## 2. GoogleService-Info.plist の配置

- ダウンロードした `GoogleService-Info.plist` を `submil/` 配下 (同期グループ) に置く。
  → `PBXFileSystemSynchronizedRootGroup` 方式なので、`submil/` 直下に置けば自動的に
    ターゲットのリソースに含まれる (pbxproj 編集不要)。
- **注意**: このファイルには API キー等が含まれる。公開リポジトリなら `.gitignore` 追加を検討
  (Firebase の iOS 用キーはクライアント公開前提だが、方針に合わせて判断)。

## 3. Swift Package の追加

Xcode で `submil.xcodeproj` を開き、**File > Add Package Dependencies…**:

- URL: `https://github.com/firebase/firebase-ios-sdk`
- Dependency Rule: **Up to Next Major Version** (推奨: v11 以降)
- Target `submil` に以下を追加:
  - `FirebaseAnalytics`

> `FirebaseAnalytics` を追加すれば `FirebaseCore` (`FirebaseApp`) も解決される。
> コードは `import FirebaseAnalytics` / `import FirebaseCore` を前提にしている。

## 4. 動作確認 (Mac / シミュレータ)

1. パッケージ追加 + plist 配置後にビルドが通ること。
2. 起動時に Firebase 初期化ログ (`Firebase ... started`) が出ること。
3. **DebugView** でイベントを確認する:
   - 起動引数に `-FIRDebugEnabled` を追加 (Scheme > Run > Arguments)。
   - Firebase Console > Analytics > DebugView にリアルタイムでイベントが流れる。
4. 主要イベントが送信されること:

   | イベント | 発生操作 | パラメータ |
   | --- | --- | --- |
   | `subscription_added` | サブスク追加を保存 | `category`, `billing_cycle` |
   | `evaluation_completed` | 「これ要る?」評価を完了 | `result` |
   | `cancellation_completed` | 解約を完了 | `annual_saving_yen` |
   | `affiliate_clicked` | 学割バナーをタップ | `service_id`, `provider` |
   | `shared` | 節約額シェアを実行 | `cancelled_count` |

## ATT (#46) との関係

- Firebase Analytics の基本計測は **ATT の許可有無に依存しない** (IDFA ではなく
  アプリインスタンス ID を使用)。ATT 拒否でも上記イベントは送信される。
- IDFA を用いた広告アトリビューション等を有効化する場合は ATT 許可が必要。
  その場合は #46 の `TrackingAuthorization.isAuthorized` を参照して制御する。

## 関連

- #45 AdMob / #46 ATT: 広告と計測の初期化はいずれも `RootView` の起動フックに集約。
- コード: `submil/Analytics/{AnalyticsEvent,AnalyticsService,FirebaseStarter}.swift`
