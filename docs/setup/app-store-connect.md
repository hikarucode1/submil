# App Store Connect / App ID セットアップ (#54)

Apple Developer Portal で App ID を作成し、Bundle ID と Capabilities を確定する手順。
コード/プロジェクト側の設定は確定済みで、以下は **Developer Portal / App Store Connect 上の手動手順**。

## 確定した識別子

| 項目 | 値 |
| --- | --- |
| App Bundle ID | **`com.hikaru.failuremuseum.submil`** |
| Team ID | `4BSH37BHRC` |
| SKU (任意) | `submil` を推奨 |
| Marketing Version | `1.0`(pbxproj `MARKETING_VERSION`) |
| Deployment Target | iOS 26.5 |

> `submilTests` / `submilUITests` はテスト専用ターゲットで、独自の Bundle ID
> (`…​.submilTests` / `…​.submilUITests`)を持つが **App ID 登録は不要**(ホストアプリに内包）。

## Capabilities 判断(このリリースの方針)

| Capability | 状態 | 理由 |
| --- | --- | --- |
| Push Notifications | **OFF** | 将来機能。今回のリリースでは使わない(#54 の明示方針)。 |
| App Groups | **OFF(今は登録しない)** | ホームウィジェット (#26) 用。Widget Extension ターゲット自体が未作成のため、本リリースのスコープ外。Widget を出す段階で #26 の手順に従いまとめて設定する。 |
| Sign in with Apple / iCloud / HealthKit 等 | OFF | 使用していない。 |

- プロジェクトには **entitlements ファイルも `com.apple.security.*` の宣言も存在しない**。
  つまり現状の App ID に必要な Capability は無く、素の App ID で足りる。
- Push を将来 ON にする場合は、App ID の Capability 追加 → provisioning profile 再生成
  (match 運用なら `fastlane certificates` を force で回す)→ コード側で APNs 登録を実装、の順。

## 1. Developer Portal で App ID を作成

[Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) >
Identifiers > **+** > App IDs > App。

- Description: `submil`
- Bundle ID: **Explicit** = `com.hikaru.failuremuseum.submil`
- Capabilities: **何も追加しない**(Push もチェックしない)
- 登録して保存。

> 署名は `CODE_SIGN_STYLE = Automatic`(pbxproj)+ fastlane `match`(App Store 用)で運用。
> App ID 作成後、`fastlane certificates` で証明書/プロファイルを同期できる。

## 2. App Store Connect にアプリレコードを作成

[App Store Connect](https://appstoreconnect.apple.com/apps) > マイ App > **+** > 新規 App。

- プラットフォーム: iOS
- 名前: ストア掲載名(#51 のメタデータと揃える)
- プライマリ言語: 日本語
- Bundle ID: 手順 1 で作成した `com.hikaru.failuremuseum.submil` を選択
- SKU: `submil`
- ユーザーアクセス: フルアクセス

作成後、メタデータ (#51) / スクリーンショット (#50) / ビルド (TestFlight, #56) を紐付けていく。

## 3. 確認

- Xcode > submil ターゲット > Signing & Capabilities で、
  **Capabilities が空**(App Groups / Push いずれも無い)であること。
- Bundle Identifier が `com.hikaru.failuremuseum.submil` であること。
- Team が `4BSH37BHRC`(渡邊光)であること。

## 関連 Issue

- #51 ストアメタデータ / #50 スクリーンショット: アプリレコード作成後に紐付け。
- #55 fastlane beta / #56 TestFlight: App ID 確定後にビルドをアップロード。
- #26 ホームウィジェット: App Groups Capability はこちらで(Widget ターゲット作成とセット)。
