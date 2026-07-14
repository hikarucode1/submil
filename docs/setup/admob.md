# AdMob バナー広告セットアップ (#45)

コード側 (`submil/Ads/`, `RootView`, `HomeView`) は実装済み。以下は **Mac / Xcode 上でのみ実施できる手動手順**。
すべてのコードは `#if canImport(GoogleMobileAds)` でガードしているため、パッケージ追加前でもビルドは通る
(バナーは表示されない no-op 状態)。

## 1. Swift Package の追加

Xcode で `submil.xcodeproj` を開き、**File > Add Package Dependencies…**:

- URL: `https://github.com/googleads/swift-package-manager-google-mobile-ads`
- Dependency Rule: **Up to Next Major Version** (推奨: v12 以降)
- Target `submil` に `GoogleMobileAds` を追加

> コードは **SDK v12 以降**の Swift API 名 (GAD プレフィックスなし) を前提にしている。
> v11 以前を解決した場合は `BannerView`→`GADBannerView` / `MobileAds`→`GADMobileAds` /
> `AdSize`→`GADAdSize` / `Request`→`GADRequest` に読み替えるか、v12+ に上げる。

## 2. Info.plist キーの追加

本プロジェクトは `GENERATE_INFOPLIST_FILE = YES`(Info.plist 自動生成)。
以下いずれかで `GADApplicationIdentifier` を追加する:

- **A. カスタム Info.plist に切替**: ターゲットに `Info.plist` を追加し `INFOPLIST_FILE` を設定、
  または
- **B. ターゲットの Info タブ**でカスタムキーを追加

追加するキー:

| キー | 値 |
| --- | --- |
| `GADApplicationIdentifier` | 開発中は `ca-app-pub-3940256099942544~1458002511`(テスト用アプリ ID)。本番は AdMob 発行値 |
| `SKAdNetworkItems` | Google 提供の SKAdNetwork ID 一覧(下記リンク参照)を配列で追加 |
| `NSUserTrackingUsageDescription` | ATT 用の説明文(#46 で対応。例: 「広告の最適化のために使用します」) |

- SKAdNetwork ID 一覧: https://developers.google.com/admob/ios/quick-start#update_your_infoplist
- テスト広告: https://developers.google.com/admob/ios/test-ads

## 3. 本番 ID への差し替え(リリース前)

`submil/Ads/AdConfig.swift` の以下を AdMob 管理画面の発行値へ置換:

- `productionApplicationID`
- `productionBannerUnitID`

併せて手順 2 の `GADApplicationIdentifier` も本番アプリ ID に更新する。
DEBUG ビルドは `AdConfig.useTestAds == true` で常にテスト広告を出すため、置換後も開発中は安全。

### 差し替え忘れ時の挙動 (重要)

`productionBannerUnitID` がプレースホルダー (`ca-app-pub-0000...`) のままの場合:

- **DEBUG**: `assertionFailure` で停止し、開発時に差し替え忘れを検知する。
- **Release (TestFlight / App Store)**: クラッシュさせず**バナー非表示**にフォールバックする
  (`AdConfig.bannerUnitID` が空文字を返し、広告ロードが不成立になる)。実ユーザーをクラッシュ
  させないための設計。ただし「広告が出ない = 収益ゼロ」に気付きにくいので、下記チェックは必ず行う。

### リリース前チェックリスト

- [ ] `AdConfig.productionBannerUnitID` を本番値に差し替えた (プレースホルダー `0000...` でない)
- [ ] `AdConfig.productionApplicationID` を本番値に差し替えた
- [ ] `Info.plist` の `GADApplicationIdentifier` が**本番アプリ ID**である (テスト用のままでない)
- [ ] Release ビルドの実機でバナーが表示され、テスト広告でないことを確認

## 4. 動作確認(Mac / シミュレータ)

1. パッケージ追加後にビルドが通ること
2. ホームタブ下部にテストバナー("Test Ad" ラベル付き)が表示されること
3. バナーがリスト内容やタブバーと重ならないこと(`safeAreaInset(edge: .bottom)` で配置)

## 関連 Issue

- #46 ATT ダイアログ: SDK 開始/計測を ATT 応答後に寄せる(`AdMobStarter` のコメント参照)
- #47 Firebase Analytics: `affiliate_clicked` 等のイベントと広告表示の整合
