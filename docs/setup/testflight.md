# TestFlight 配信 / テスター招待 (#56)

`fastlane beta`(#55)でビルドを TestFlight にアップロードした後の、内部テスター招待と
外部ベータ申請の手順。大半は App Store Connect (ASC) 上の手動作業。

## 前提

- App レコード作成済み(#54, `docs/setup/app-store-connect.md`)。
- `fastlane beta` の認証(ASC API Key)・署名(match)が設定済み(#55, `docs/setup/fastlane.md`)。
- **輸出コンプライアンス**は `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` を
  pbxproj に設定済み(HTTPS 等の標準暗号のみ = 適用除外)。これにより TestFlight で
  ビルドごとに輸出コンプライアンスを手動回答する必要がなくなる。

## 1. ビルドをアップロード

```sh
bundle exec fastlane beta
```

- 直近 TestFlight ビルド +1 の番号を採番 → archive/ipa → アップロード。
- `skip_waiting_for_build_processing: true` のため、アップロード後 ASC 側で数分〜十数分の
  「処理中」を経て利用可能になる。

## 2. 内部テスター(自分 + 友人 2-3 人)

内部テスターは **Apple のベータ審査が不要**で、アップロード後すぐに配信できる。

1. ASC > マイ App > submil > **TestFlight** > **内部テスト** グループ。
2. テスターは ASC の **Users and Access** に登録された Apple ID のみ(最大 100 人)。
   友人を内部にする場合は先に ASC ユーザー(App Manager / Developer 等)として招待。
3. グループに最新ビルドを割り当て → テスターに招待メール。
4. テスターは iOS の **TestFlight アプリ**で受諾してインストール。

> 内部テスターは新ビルドを自動で受け取れる(ビルドごとの割り当ては任意)。

## 3. 外部ベータ(一般公開ベータ)

外部テスターは **Apple のベータ審査(通常 24-48h)**が必要。

1. TestFlight > **外部テスト** グループを作成(例: `外部ベータ`)。
2. **テスト情報**を入力(初回の外部ベータ審査で必須):
   - ベータ App の説明
   - フィードバックメールアドレス
   - 連絡先(氏名 / メール / 電話)
   - 「テスト内容(What to Test)」= このビルドの確認ポイント
3. グループにビルドを割り当て → **審査に提出**。
4. 承認後、以下いずれかでテスターを追加:
   - メール招待(個別 Apple ID)
   - **公開リンク**(URL を共有、上限人数を設定可能。SNS 等で配布可)

> 外部ベータは最大 10,000 人。公開リンクは審査済みビルドに対してのみ有効。

## fastlane からの外部配信(任意)

`beta` レーンは既定で内部向け(`distribute_external: false`)。外部グループへ自動割り当て・
通知したい場合は `upload_to_testflight` に以下を渡すレーンを追加できる(値は運用者依存のため
既定レーンには入れていない):

```ruby
upload_to_testflight(
  api_key: key,
  app_identifier: APP_IDENTIFIER,
  distribute_external: true,
  groups: ["外部ベータ"],
  notify_external_testers: true,
  changelog: "今回の確認ポイント…",
  beta_app_review_info: {
    contact_email: "…",
    contact_first_name: "光",
    contact_last_name: "渡邊",
    contact_phone: "…"
  }
)
```

> 初回の外部ベータ審査提出は ASC の Web UI で行うのが確実。以降のビルド差し替えは
> fastlane で回せる。

## チェックリスト

- [ ] `fastlane beta` でビルドをアップロード
- [ ] ASC でビルドが「処理済み」になる
- [ ] 内部テストグループに自分 + 友人を追加、招待
- [ ] TestFlight アプリで受諾・インストール・一通り動作確認
- [ ] 外部テストグループを作成、テスト情報を入力
- [ ] 外部ベータを審査提出(24-48h)
- [ ] 承認後、公開リンク/メールでテスター募集

## 関連

- #55 fastlane(`docs/setup/fastlane.md`)
- #54 App Store Connect 設定(`docs/setup/app-store-connect.md`)
- #50 スクリーンショット / #51 メタデータ(ストア提出用。ベータには必須ではない)
