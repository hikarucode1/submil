# App Store Connect / App ID セットアップ (#54)

Apple Developer Portal で App ID を作成し、Bundle ID と Capabilities を確定する手順。
コード/プロジェクト側の設定は確定済みで、以下は **Developer Portal / App Store Connect 上の手動手順**。

## 確定した識別子

| 項目 | 値 |
| --- | --- |
| App Bundle ID | **`com.hikaru.failuremuseum.submil`** |
| Widget Bundle ID | **`com.hikaru.failuremuseum.submil.submilWidget`**(#26 で追加) |
| App Group | **`group.com.hikaru.failuremuseum.submil`**(app ⇄ widget 共有) |
| Team ID | `4BSH37BHRC` |
| SKU (任意) | `submil` を推奨 |
| Marketing Version | `1.0`(pbxproj `MARKETING_VERSION`) |
| Deployment Target | iOS 26.5 |

> `submilTests` / `submilUITests` はテスト専用ターゲットで、独自の Bundle ID
> (`…​.submilTests` / `…​.submilUITests`)を持つが **App ID 登録は不要**(ホストアプリに内包）。
>
> Widget Extension (`submilWidget`) は #26 で追加済み。App Extension は**独自の App ID 登録が必要**で、
> app 本体とともに App Groups Capability を持つ。

## Capabilities 判断(このリリースの方針)

| Capability | 状態 | 理由 |
| --- | --- | --- |
| Push Notifications | **OFF** | 将来機能。今回のリリースでは使わない(#54 の明示方針)。 |
| App Groups | **ON**(#26 で追加) | ホームウィジェット (#26) の app ⇄ widget データ共有。app / widget 両ターゲットに entitlements 配線済み。**app・widget 両 App ID で有効化 + App Group `group.com.hikaru.failuremuseum.submil` を作成・紐付けが必要**。 |
| Sign in with Apple / iCloud / HealthKit 等 | OFF | 使用していない。 |

- プロジェクトに存在する entitlements は **App Groups のみ**
  (`submil/submil.entitlements` / `submilWidget/submilWidget.entitlements`)。Push その他は無い。
- したがって App ID には **App Groups Capability の有効化**が必要(下記手順 1)。
  シミュレータは Portal 登録なしで動くが、実機 / TestFlight / 審査には Portal 設定が要る。
- Push を将来 ON にする場合は、App ID の Capability 追加 → provisioning profile 再生成
  (match 運用なら `fastlane certificates` を force で回す)→ コード側で APNs 登録を実装、の順。

## 1. Developer Portal で App ID / App Group を作成

[Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) で以下を作成する。

### 1-a. App Group を作成

Identifiers > **+** > **App Groups**:

- Description: `submil app group`
- Identifier: **`group.com.hikaru.failuremuseum.submil`**(`WidgetSharedConfig.appGroupID` と一致)

### 1-b. App 本体の App ID

Identifiers > **+** > App IDs > App:

- Description: `submil`
- Bundle ID: **Explicit** = `com.hikaru.failuremuseum.submil`
- Capabilities: **App Groups を ON** → 1-a で作った App Group を選択(Push はチェックしない)
- 登録して保存。

### 1-c. Widget の App ID(#26)

Identifiers > **+** > App IDs > App:

- Description: `submil widget`
- Bundle ID: **Explicit** = `com.hikaru.failuremuseum.submil.submilWidget`
- Capabilities: **App Groups を ON** → 同じ App Group を選択
- 登録して保存。

> 署名は `CODE_SIGN_STYLE = Automatic`(pbxproj)+ fastlane `match`(App Store 用)で運用。
> App ID 作成後、`fastlane certificates`(必要なら force)で app・widget 両方の
> 証明書/プロファイルを同期する。App Groups を後から足した場合はプロファイル再生成が要る。

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

- Xcode > **submil** / **submilWidget** 両ターゲット > Signing & Capabilities に
  **App Groups**(`group.com.hikaru.failuremuseum.submil`)があり、Push は無いこと。
- Bundle Identifier が `com.hikaru.failuremuseum.submil` /
  `com.hikaru.failuremuseum.submil.submilWidget` であること。
- Team が `4BSH37BHRC`(渡邊光)であること。
- App Group container が実機で共有されること(シミュレータでは Portal 登録なしで確認済み。
  詳細は `docs/setup/widget.md`)。

## 関連 Issue

- #51 ストアメタデータ / #50 スクリーンショット: アプリレコード作成後に紐付け。
- #55 fastlane beta / #56 TestFlight: App ID 確定後にビルドをアップロード。
- #26 ホームウィジェット: Widget ターゲット + App Groups entitlements は配線済み
  (`docs/setup/widget.md`)。Portal 側の App Group / Capability は上記手順 1 に統合した。
