# Changelog

すべてのテンプレート・スクリプトの変更履歴。

フォーマット: [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/)
バージョン管理: [Semantic Versioning](https://semver.org/lang/ja/)

---

## [v1.0.0] - 2026-03-15

### Added

#### テンプレート
- `templates/base/workflow-base-v1.0.0.yaml` — ベーステンプレ（Dify v0.6.0対応）
- `templates/line-concierge/line-daigen-v1.0.0.yaml` — LINEコンシェルジュ大元（実稼働）
- `templates/line-concierge/line-concierge-phaseflow-v1.0.0.yaml` — LINEコンシェルジュPhaseFlow（実稼働）
- `templates/housing-loan/housing-loan-v1.0.0.yaml` — 住宅ローン相談テンプレ
- `templates/minpaku/minpaku-v1.0.0.yaml` — 民泊問い合わせテンプレ
- `templates/marriage-consultation/marriage-consultation-v1.0.0.yaml` — 結婚相談所テンプレ

#### スキーマ
- `schemas/dify-workflow.base.schema.json` — Dify v0.6.0ベーススキーマ
- `schemas/dify-workflow.line-concierge.schema.json` — LINEコンシェルジュ拡張スキーマ
- `schemas/dify-workflow.housing-loan.schema.json` — 住宅ローン特化スキーマ
- `schemas/dify-workflow.minpaku.schema.json` — 民泊特化スキーマ
- `schemas/dify-workflow.marriage-consultation.schema.json` — 結婚相談所スキーマ

#### スクリプト
- `scripts/validate-dsl.sh` — メイン検証スクリプト（5段階検証）
- `scripts/check_node_connectivity.py` — ノード接続チェック
- `scripts/check_circular_references.py` — 循環参照チェック
- `scripts/detect_unused_nodes.py` — 未使用ノード検出
- `scripts/merge-patch.sh` — パッチ適用スクリプト
- `scripts/install-tools.sh` — 初回セットアップスクリプト

#### ドキュメント
- `docs/01_QuickStart.md` — 非エンジニア向け5分ガイド
- `docs/02_WorkflowPatterns.md` — よくある修正パターン集
- `docs/03_NodeReferenceGuide.md` — ノード種別リファレンス
- `docs/04_SchemaValidation.md` — スキーマ検証の仕組み
- `docs/05_GitWorkflow.md` — Git操作ガイド
- `docs/06_TroubleshootingGuide.md` — トラブル対応集
- `docs/07_TemplateManagement.md` — テンプレ更新・追加手順

#### CI/CD
- `.github/workflows/validate-on-push.yml` — Push時の自動検証
- `.github/workflows/validate-pr.yml` — PR時の自動検証
- `.github/workflows/generate-validation-report.yml` — 週次レポート生成

---

<!-- 以降のエントリはここに追記 -->
