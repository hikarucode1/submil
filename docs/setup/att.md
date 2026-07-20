# App Tracking Transparency (ATT) セットアップ (#46)

コード側は実装済み。ATT の許可要求 → AdMob 初期化の順で動くよう配線してある。

## 実装済みの内容

- `submil/Privacy/TrackingAuthorization.swift`: ATT の許可要求ラッパー。
  ステータスが `.notDetermined` の時だけダイアログを提示し、応答を待つ。
  `#if canImport(AppTrackingTransparency)` ガードでパッケージ非依存。
- `submil/Ads/AdMobStarter.swift`: `startAfterTrackingAuthorization()` を追加。
  ATT 応答後(許可/拒否に関わらず)に SDK を開始する(Google 推奨フロー)。
- `submil/Views/RootView.swift`: `scenePhase == .active` への初回遷移で一度だけ
  ATT → AdMob 初期化を実行(`didStartAds` フラグで多重実行を防止)。
  ATT ダイアログは app が active でないと表示されないため active を待つ。
- `Info.plist` の `NSUserTrackingUsageDescription`: pbxproj の
  `INFOPLIST_KEY_NSUserTrackingUsageDescription`(Debug/Release 両方)に設定済み。
  現在の文言: 「広告をあなたの興味に合わせて最適化するために使用します。許可しなくてもアプリはそのままご利用いただけます。」

## Mac / Xcode 上で必要な確認

`AppTrackingTransparency` は iOS SDK に含まれる標準フレームワークのため、SPM 追加は不要。
以下を実機/シミュレータで確認する:

1. 初回起動時、app が前面に来たタイミングで ATT ダイアログが 1 回だけ表示される。
2. ダイアログの説明文が `NSUserTrackingUsageDescription` の文言になっている。
3. 「許可」「許可しない」いずれを選んでも app が正常に続行し、バナー広告が表示される
   (テスト広告は ATT の結果に関わらず表示される)。
4. 2 回目以降の起動ではダイアログが再表示されない(`.notDetermined` 以外はスキップ)。
5. 設定 > プライバシーとセキュリティ > トラッキング で許可をリセットすると再度表示される。

> シミュレータでは ATT ダイアログが出ない/挙動が不安定なことがある。実機での確認を推奨。

## 文言の調整

`NSUserTrackingUsageDescription` は審査対象。「なぜトラッキングするか」をユーザーに伝わる形で
記載する必要がある。変更する場合は pbxproj の `INFOPLIST_KEY_NSUserTrackingUsageDescription`
(Debug/Release の 2 箇所)を編集する。

## 関連 Issue

- #45 AdMob: ATT 応答後に SDK を開始するよう `AdMobStarter` を配線済み。
- #47 Firebase Analytics: 計測イベントも ATT の許可状況に整合させること。
