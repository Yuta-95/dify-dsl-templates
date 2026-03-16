# dify-dsl-templates

**いえすま Dify DSL 開発基盤** — 住宅ローン・民泊・結婚相談所のDify Chatflowワークフローを、Git管理・自動検証・テンプレ化で標準化する開発インフラ。

---

## 概要

| 項目 | 内容 |
|---|---|
| 対象 | Dify v0.6.0 advanced-chat / workflow |
| 管理案件 | 住宅ローン相談、民泊問い合わせ、結婚相談所、LINEコンシェルジュ |
| 検証ツール | yamllint, Python (pyyaml, networkx), bash |
| CI/CD | GitHub Actions（Push・PR・週次レポート） |

---

## ディレクトリ構成

```
dify-dsl-templates/
├── templates/                     # DSLテンプレート（業界別）
│   ├── base/                      # ベーステンプレ
│   ├── line-concierge/            # LINEコンシェルジュ（実稼働ファイル）
│   ├── housing-loan/              # 住宅ローン相談
│   ├── minpaku/                   # 民泊問い合わせ
│   └── marriage-consultation/     # 結婚相談所
│
├── schemas/                       # Dify DSL JSON Schemaスキーマ定義
│
├── scripts/                       # 検証・管理スクリプト
│   ├── validate-dsl.sh            # ★ メイン検証（ワンコマンド）
│   ├── check_node_connectivity.py # ノード接続チェック
│   ├── check_circular_references.py # 循環参照チェック
│   ├── detect_unused_nodes.py     # 未使用ノード検出
│   ├── merge-patch.sh             # パッチ適用
│   └── install-tools.sh           # 初回セットアップ
│
├── patches/examples/              # パッチファイルサンプル
│
├── docs/                          # ドキュメント
│   ├── 01_QuickStart.md           # ★ 非エンジニア向け5分ガイド
│   ├── 02_WorkflowPatterns.md     # よくある修正パターン
│   ├── 03_NodeReferenceGuide.md   # ノード種別リファレンス
│   ├── 04_SchemaValidation.md     # 検証の仕組み
│   ├── 05_GitWorkflow.md          # Git操作ガイド
│   ├── 06_TroubleshootingGuide.md # ★ トラブル対応集
│   └── 07_TemplateManagement.md   # テンプレ更新手順
│
└── .github/workflows/             # GitHub Actions
    ├── validate-on-push.yml       # Push時の自動検証
    ├── validate-pr.yml            # PR時の自動検証
    └── generate-validation-report.yml # 週次レポート
```

---

## クイックスタート

### 1. 初回セットアップ（1回だけ）

```bash
git clone https://github.com/[あなたのアカウント]/dify-dsl-templates.git
cd dify-dsl-templates
./scripts/install-tools.sh
```

### 2. テンプレから新しいワークフローを作る

```bash
# テンプレをコピー
cp templates/housing-loan/housing-loan-v1.0.0.yaml my-new-flow.yaml

# プロンプト等を修正してから検証
./scripts/validate-dsl.sh my-new-flow.yaml
```

### 3. Difyにインポートする

1. Dify管理画面 → 「アプリを作成」
2. 「DSLファイルからインポート」
3. `my-new-flow.yaml` をアップロード

---

## 推奨テンプレ

| 用途 | 推奨テンプレ | バージョン |
|---|---|---|
| LINEコンシェルジュ（大元） | `templates/line-concierge/line-daigen-v1.0.0.yaml` | v1.0.0（実稼働） |
| LINEコンシェルジュ（受付） | `templates/line-concierge/line-concierge-phaseflow-v1.0.0.yaml` | v1.0.0（実稼働） |
| 住宅ローン相談 | `templates/housing-loan/housing-loan-v1.0.0.yaml` | v1.0.0 |
| 民泊問い合わせ | `templates/minpaku/minpaku-v1.0.0.yaml` | v1.0.0 |
| 結婚相談所 | `templates/marriage-consultation/marriage-consultation-v1.0.0.yaml` | v1.0.0 |
| ゼロから作る | `templates/base/workflow-base-v1.0.0.yaml` | v1.0.0 |

---

## ドキュメント

- **初めての方** → [docs/01_QuickStart.md](docs/01_QuickStart.md)
- **エラーが出たとき** → [docs/06_TroubleshootingGuide.md](docs/06_TroubleshootingGuide.md)
- **プロンプトを変えたい** → [docs/02_WorkflowPatterns.md](docs/02_WorkflowPatterns.md)
- **Git操作がわからない** → [docs/05_GitWorkflow.md](docs/05_GitWorkflow.md)

---

## 注意事項

- APIキー・シークレット情報は `.env` に書き、Gitには絶対コミットしない
- 本番環境用のテンプレはバージョンを上げて管理すること（旧バージョンは残す）
- Difyにインポートする前に必ず `validate-dsl.sh` を通すこと
