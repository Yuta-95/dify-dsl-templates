# スキーマ検証の仕組み

---

## 検証の全体像

`validate-dsl.sh` は以下の5段階で検証を実行する。

```
YAML構文 → 必須フィールド → ノード接続 → 循環参照 → 未使用ノード
```

各ステップがPASSして初めて「Difyへのインポートが安全」と判断できる。

---

## 各検証の詳細

### 1. YAML構文チェック（yamllint）

**何をチェックするか**: YAMLとして有効なファイルか

よく検出されるエラー：
- インデントが不揃い（タブ・スペース混在）
- 重複キー（同じキーが2回定義されている）
- クォートの閉じ忘れ

```bash
# 単独で実行する場合
yamllint -d "{extends: default, rules: {line-length: {max: 300}}}" your-file.yaml
```

---

### 2. 必須フィールド確認（Python + pyyaml）

**何をチェックするか**: Dify DSLとして最低限必要なフィールドが揃っているか

チェック対象：
- トップレベル: `app`, `kind`, `version`, `workflow`
- `app`: `name`, `mode`
- `workflow.graph`: `nodes`, `edges`
- nodes: 最低2個、`start` タイプが1個存在

---

### 3. ノード接続チェック（check_node_connectivity.py）

**何をチェックするか**: ノードが正しくつながっているか

検出する問題：
- 存在しないノードへのエッジ参照（IDのタイポ等）
- 孤立ノード（どのエッジにも登場しない）
- デッドエンド（出力エッジがないノード）

---

### 4. 循環参照チェック（check_circular_references.py）

**何をチェックするか**: 無限ループになる経路がないか

例：`A → B → C → A` という循環があると、Dify上でワークフローが終わらない。

DFS（深さ優先探索）アルゴリズムで全経路を探索する。

---

### 5. 未使用ノード検出（detect_unused_nodes.py）

**何をチェックするか**: どのフローにも属さない「浮いたノード」がないか

未使用ノードは警告（Warning）扱いで、検証は通過する。
ただし、削除推奨（Dify UI上でも削除できる）。

---

## スキーマファイルの場所

```
schemas/
├── dify-workflow.base.schema.json             # Dify v0.6.0 基本スキーマ
├── dify-workflow.line-concierge.schema.json   # LINEコンシェルジュ拡張スキーマ
├── dify-workflow.housing-loan.schema.json     # 住宅ローン特化スキーマ
├── dify-workflow.minpaku.schema.json          # 民泊特化スキーマ
└── dify-workflow.marriage-consultation.schema.json
```
