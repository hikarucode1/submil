# ホームウィジェット セットアップ (#26)

WidgetKit で月額合計を表示するホーム画面ウィジェット (Small / Medium)。
SwiftData ストアは共有せず、**アプリが集計値 (月額合計・件数) を App Group の共有 UserDefaults に
書き出し、ウィジェットはそれを読むだけ**の軽量方式(SwiftData 非依存・App エントリの ModelContainer 変更なし)。

コード側 (`submil/Widget/`, `submilWidget/`, HomeView フック) と **Widget Extension ターゲット
`submilWidget` は作成済み**(#26 / feat/26-widget-target)。app へ埋め込み、App Groups entitlements
(`submil/submil.entitlements` / `submilWidget/submilWidget.entitlements`) も配線済みで、
シミュレータでは App Group 共有・ウィジェット表示まで動作する。

**残る手動手順は Developer Portal での App Group 作成のみ**(実機/TestFlight/審査向け。下記「Developer Portal」節)。

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

## プロジェクトに設定済みの内容 (feat/26-widget-target)

Widget Extension ターゲットは `xcodeproj` gem スクリプトで pbxproj に追加済み。手動の
Xcode 操作は不要。設定内容:

- ターゲット `submilWidget`(app-extension)、Bundle ID `com.hikaru.failuremuseum.submil.submilWidget`
- Sources: `submilWidget/` の 3 ファイル + 共有 `submil/Widget/` の 3 ファイル
  (`WidgetSharedConfig` / `SubscriptionSnapshot` / `WidgetDataStore`)を明示参照で追加。
  `WidgetSnapshotUpdater.swift` は `Subscription` (@Model) 依存のため **widget には含めない**。
- app に Embed Foundation Extensions で `submilWidget.appex` を埋め込み + target dependency
- `submilWidget/Info.plist`: `NSExtension > NSExtensionPointIdentifier = com.apple.widgetkit-extension`
  (`INFOPLIST_KEY_` では注入されないため明示 plist。標準キーは `GENERATE_INFOPLIST_FILE=YES` から自動マージ)
- App Groups entitlements を app / widget 両方に配線
  (`submil/submil.entitlements` / `submilWidget/submilWidget.entitlements` = `group.com.hikaru.failuremuseum.submil`)
- Deployment Target 26.5(`containerBackground` 使用のため iOS 17+ 必須を満たす)

## Developer Portal (実機 / TestFlight / 審査向け)

シミュレータは Portal 登録なしで App Group が機能するが、実機配布には Portal 設定が必要:

1. Developer Portal > Identifiers > **App Groups** で `group.com.hikaru.failuremuseum.submil` を作成。
2. app (`…​.submil`) と widget (`…​.submilWidget`) の両 App ID で **App Groups** Capability を有効化し、
   上記グループに紐付け。
3. `fastlane match`(App Store)を再生成し、両 App ID 分の provisioning profile を取得。

## 動作確認 (シミュレータで確認済み)

1. `xcodebuild build -scheme submil` で app + widget がビルドできる。**✅ 確認済み**
2. app を起動しホームタブを表示(`HomeView` の `.onChange(initial: true)` で初回スナップショットが書かれる)
   → App Group 共有コンテナに `widget.subscriptionSnapshot` が書き込まれる。**✅ 確認済み**
3. ホーム画面でウィジェットギャラリーから「月額合計」を追加。Small / Medium で月額合計と件数が出る。
4. app でサブスクを追加 / 解約 → ホームタブを開く → ウィジェットが更新される
   (`WidgetDataStore.save` が `reloadTimelines` を呼ぶ)。
5. 未登録時は `¥0 / 登録中 0件` になる。

## 設計メモ

- SwiftData を App Group 共有にする案もあるが、その場合 App エントリの `ModelContainer` を
  共有コンテナへ変更する必要があり根幹変更になる。月額合計のみの要件では**集計値スナップショット**で十分。
- スナップショット更新は `HomeView` の集計変更 1 箇所に集約(追加/解約/削除すべて @Query に反映される)。

## 関連 Issue

- #26 ホームウィジェット(任意・p3)
