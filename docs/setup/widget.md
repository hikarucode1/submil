# ホームウィジェット セットアップ (#26)

WidgetKit で月額合計を表示するホーム画面ウィジェット (Small / Medium)。
SwiftData ストアは共有せず、**アプリが集計値 (月額合計・件数) を App Group の共有 UserDefaults に
書き出し、ウィジェットはそれを読むだけ**の軽量方式(SwiftData 非依存・App エントリの ModelContainer 変更なし)。

コード側 (`submil/Widget/`, `submilWidget/`, HomeView フック) は実装済み。以下は
**Mac / Xcode 上でのみ実施できる手動手順**(新規ターゲット作成・App Group 権限)。

## ファイル構成

| ファイル | ターゲット |
| --- | --- |
| `submil/Widget/WidgetSharedConfig.swift` | **app + widget 両方** |
| `submil/Widget/SubscriptionSnapshot.swift` | **app + widget 両方** |
| `submil/Widget/WidgetDataStore.swift` | **app + widget 両方** |
| `submil/Widget/WidgetSnapshotUpdater.swift` | **app のみ**(`Subscription` に依存) |
| `submilWidget/SubmilWidget.swift` | **widget のみ** |
| `submilWidget/SubmilWidgetView.swift` | **widget のみ** |
| `submilWidget/SubmilWidgetBundle.swift` | **widget のみ** |

## 1. Widget Extension ターゲットを追加

Xcode > File > New > Target… > **Widget Extension**。

- Product Name: `submilWidget`
- **Include Live Activity**: オフ / **Include Configuration App Intent**: オフ(StaticConfiguration を使用)
- Activate scheme のダイアログは Activate。

生成された雛形の `.swift`(`submilWidget.swift` 等)は**削除**し、本リポの
`submilWidget/` 配下の 3 ファイルを widget ターゲットに含める(同期グループなら自動)。

## 2. 共有ファイルを widget ターゲットにも追加

`submil/Widget/` の以下 3 ファイルを選択し、File Inspector の **Target Membership** で
`submilWidget` にもチェックを入れる(app は同期グループで自動所属):

- `WidgetSharedConfig.swift` / `SubscriptionSnapshot.swift` / `WidgetDataStore.swift`

> `WidgetSnapshotUpdater.swift` は `Subscription` (@Model) に依存するので **widget には追加しない**。

## 3. App Group を両ターゲットに追加

`submil` と `submilWidget` の両方で Signing & Capabilities > **+ Capability > App Groups**:

- グループ ID: **`group.com.hikaru.failuremuseum.submil`**
  (`WidgetSharedConfig.appGroupID` と一致させる。異なる場合はコード側を合わせる)
- Developer Portal 側でも同 ID の App Group を作成し、両 App ID に紐付ける。

## 4. デプロイターゲット

widget ターゲットの iOS Deployment Target を app と揃える(本コードは `containerBackground` を
使うため **iOS 17 以上**が必要。本プロジェクトは iOS 26.5)。

## 5. 動作確認 (Mac / 実機・シミュレータ)

1. app と widget がビルドできること。
2. app を一度起動しホームタブを表示(`HomeView` の `.onChange(initial: true)` で初回スナップショットが書かれる)。
3. ホーム画面でウィジェットギャラリーから「サブミル / 月額合計」を追加。Small / Medium で月額合計と件数が出る。
4. app でサブスクを追加 / 解約 → ホームタブを開く → ウィジェットが更新される
   (`WidgetDataStore.save` が `reloadTimelines` を呼ぶ)。
5. 未登録時は `¥0 / 登録中 0件` になる。

> App Group が未設定のうちは `WidgetSharedConfig.sharedDefaults` が共有領域にならず、
> ウィジェットは `.empty`(¥0)を表示する。手順 3 完了後に正しく共有される。

## 設計メモ

- SwiftData を App Group 共有にする案もあるが、その場合 App エントリの `ModelContainer` を
  共有コンテナへ変更する必要があり根幹変更になる。月額合計のみの要件では**集計値スナップショット**で十分。
- スナップショット更新は `HomeView` の集計変更 1 箇所に集約(追加/解約/削除すべて @Query に反映される)。

## 関連 Issue

- #26 ホームウィジェット(任意・p3)
