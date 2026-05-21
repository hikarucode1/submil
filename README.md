# サブミル (submil)

> 「あなたのサブスク、チャント見てる?」

大学生向けサブスク見直し特化のiOSアプリ。手入力でサブスクを棚卸し、不要なものを発見し、解約・乗り換え (学割版) をサポートする。

## ステータス

🚧 **開発初期** — フェーズ4 (技術選定) 完了、フェーズ5 (MVP実装) 着手中

## 技術スタック

- **言語/UI:** Swift + SwiftUI (iOS 17+)
- **データストア:** SwiftData
- **コンテンツ配信:** GitHub Pages 静的JSON
- **分析:** Firebase Analytics + Crashlytics
- **広告:** Google AdMob
- **アフィリエイト:** A8.net + バリューコマース
- **CI/CD:** TestFlight + fastlane + GitHub Actions

## 設計ドキュメント

詳細な市場調査、コンセプト選定、MVP仕様、技術選定は Obsidian Vault に集約:

- `~/Documents/Obsidian Vault/01-Projects/サブミル/README.md` — プロジェクトハブ・意思決定ログ
- `~/Documents/Obsidian Vault/01-Projects/サブミル/research/`
  - `01-market-research.md` — 競合6社分析、市場規模、ホワイトスペース仮説
  - `02-product-concepts.md` — 5コンセプト比較、Concept B 採用理由
  - `03-mvp-definition.md` — MVP仕様、画面構成、ユーザーフロー、KPI
  - `04-tech-selection.md` — 技術スタック、コスト試算、リスク

## 構造 (予定)

```
submil/
├── README.md
├── .gitignore
├── submil.xcodeproj/        # (Xcode で作成予定)
├── submil/                  # SwiftUI ソース
│   ├── App/
│   ├── Models/              # SwiftData
│   ├── Views/
│   ├── Services/
│   └── Resources/
└── submilTests/
```

## MVP スコープ (フェーズ5)

1. オンボーディング (3スクリーン)
2. ホーム (サブスク一覧 + 月額/年額合計)
3. サブスク詳細
4. サブスク追加 (手入力、主要30サービスからサジェスト)
5. 「これ要る?」評価フロー
6. 解約ガイド
7. シェア画面 (年間節約額OGP画像)

## 開発開始手順

1. Xcode で SwiftUI App プロジェクトを作成 (Bundle ID: `com.hikarucode1.submil` 仮)
2. iOS 17.0+ デプロイメントターゲット
3. SwiftData を有効化
4. このリポジトリ直下にプロジェクトを配置 (`submil.xcodeproj`)

## ライセンス

未定 (個人開発・商用予定)
