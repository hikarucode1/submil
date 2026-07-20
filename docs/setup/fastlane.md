# fastlane セットアップ (#55)

`fastlane beta` で archive → ipa → TestFlight アップロード、`fastlane upload_metadata` で
ストアメタデータ (#51) 反映を行う。証明書は match、認証は App Store Connect API Key。
ローカル(Mac)でも GitHub Actions でも同じレーンを実行できる。

## 構成ファイル

| ファイル | 役割 |
| --- | --- |
| `Gemfile` | fastlane を bundler で固定 |
| `fastlane/Appfile` | app_identifier / team_id |
| `fastlane/Fastfile` | レーン定義 (`beta` / `upload_metadata` / `certificates`) |
| `fastlane/Deliverfile` | deliver (メタデータ) の既定値 |
| `fastlane/Matchfile` | match (証明書) の設定 |
| `fastlane/metadata/ja/` | ストア文言 (#51) |
| `.env.example` | 環境変数サンプル |
| `.github/workflows/testflight.yml` | CI から手動実行 |
| `submil.xcodeproj/.../xcschemes/submil.xcscheme` | 共有スキーム (CI ビルドに必須) |

## レーン

| コマンド | 内容 |
| --- | --- |
| `bundle exec fastlane beta` | 署名同期 → ビルド番号採番 → archive/ipa → TestFlight アップロード |
| `bundle exec fastlane upload_metadata` | `fastlane/metadata` を App Store Connect へ反映 (バイナリ・スクショは送らない) |
| `bundle exec fastlane certificates` | match で証明書/プロファイルを同期 |

- ビルド番号は直近 TestFlight ビルド +1 を `CURRENT_PROJECT_VERSION` としてビルド時に上書き
  (Info.plist 自動生成のため pbxproj は変更しない)。

## 事前準備 (Mac / 各種コンソール)

### 1. ツール

```sh
brew install fastlane        # または gem install bundler && bundle install
bundle install
```

### 2. App Store Connect API Key

App Store Connect > Users and Access > Integrations > App Store Connect API でキーを発行し、
`.p8` をダウンロード。以下を控える:

- Key ID → `ASC_KEY_ID`
- Issuer ID → `ASC_ISSUER_ID`
- `.p8` の base64 → `ASC_KEY_CONTENT`
  ```sh
  base64 -i AuthKey_XXXX.p8 | tr -d '\n'
  ```

### 3. match 用の private リポジトリ

証明書を暗号化保管する **private** git リポジトリ(例: `hikarucode1/submil-certs`)を作成し、
URL を `MATCH_GIT_URL`、暗号化パスフレーズを `MATCH_PASSWORD` に設定。初回のみ Mac で:

```sh
bundle exec fastlane match appstore        # 証明書とプロファイルを生成し private リポへ保存
```

> App Store Connect に App レコード (Bundle ID `com.hikaru.failuremuseum.submil`) が
> 事前に必要 (#54)。

### 4. 共有スキーム

`submil.xcscheme` は本 PR で共有スキームとして追加済み。Xcode で開いた際は
Product > Scheme > Manage Schemes… の `submil` に **Shared** チェックが入っていることを確認する。

## ローカル実行

```sh
cp .env.example .env        # 値を記入 (.env は gitignore 済み)
bundle exec fastlane beta
```

## GitHub Actions

`Actions > TestFlight > Run workflow` で `beta` / `upload_metadata` を選んで手動実行。
以下を **Repository Secrets** に登録する:

| Secret | 用途 |
| --- | --- |
| `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_KEY_CONTENT` | ASC API Key |
| `MATCH_GIT_URL` | 証明書 private リポの URL |
| `MATCH_PASSWORD` | match パスフレーズ |
| `MATCH_GIT_BASIC_AUTHORIZATION` | 証明書リポ clone 用。`base64("<user>:<PAT>")` |

## 注意 (iOS 26.5 ターゲット)

本プロジェクトは iOS 26.5 / Xcode 26 系で作成されている。GitHub ホストランナーのイメージに
対応 Xcode が載るまでは、`beta` レーンのビルドが SDK 不一致で失敗する可能性がある。
その間は Mac ローカルでの `fastlane beta` 実行、または対応 Xcode を持つ self-hosted ランナー
利用を検討する。`upload_metadata` はビルド不要なのでランナーの Xcode 版に依存しない。

## 関連

- #51 ストアメタデータ (`fastlane/metadata/ja/`, `docs/store/app-store-listing.md`)
- #54 App Store Connect 設定 (App レコード作成)
- #56 TestFlight テスター招待
