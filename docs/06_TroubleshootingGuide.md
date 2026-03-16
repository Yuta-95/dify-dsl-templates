# トラブルシューティングガイド

---

## 検証エラー編

### ❌ 「必須フィールド 'workflow' が存在しません」

**原因**: ファイルの構造が根本的に壊れている。

**対処法**:
```yaml
# ✅ 正しい構造（ファイル先頭から）
app:
  name: "..."
  mode: advanced-chat
kind: app
version: 0.6.0
workflow:
  graph:
    edges: []
    nodes: []
```

---

### ❌ 「ノード数が少なすぎます（1個、最低2個必要）」

**原因**: `workflow.graph.nodes` 配列が空または1個しかない。

**対処法**: start ノードと answer/end ノードを最低2つ用意する。

---

### ❌ 「'start' タイプのノードが存在しません」

**原因**: `data.type: start` のノードがない。

**対処法**: 以下のノードを `nodes:` に追加する：
```yaml
- data:
    type: start
    title: ユーザー入力
    variables: []
  id: node-start
  type: custom
  position:
    x: 0
    y: 200
  width: 242
  height: 73
  sourcePosition: right
  targetPosition: left
```

---

### ❌ 「エッジの source ノード 'xxx' が nodes に存在しません」

**原因**: エッジで参照しているノードIDが `nodes` に存在しない。

**対処法**:
1. 該当エッジの `source` / `target` を確認
2. `nodes` のIDと一致しているか確認
3. タイポがないか確認（大文字小文字も区別される）

```bash
# 全ノードIDを確認するコマンド
grep "^  id:" templates/your-file.yaml
```

---

### ❌ 「孤立ノード: 'xxx' はどのエッジにも接続されていません」

**原因**: そのノードがどのエッジにも現れていない（フローの中に入っていない）。

**対処法**:
- ノードが不要なら削除する
- 必要なら適切なエッジを追加する

---

### ❌ 「デッドエンド: 'xxx' に出力エッジがありません」

**原因**: そのノードから次のノードへのエッジが存在しない（処理が止まってしまう）。

**対処法**:
```yaml
# 出力エッジを追加
edges:
- source: dead-end-node-id
  target: next-node-id
  id: dead-end-node-id-source-next-node-id-target
  sourceHandle: source
  targetHandle: target
  type: custom
  zIndex: 0
  data:
    isInLoop: false
    sourceType: code
    targetType: answer
```

---

### ❌ 「YAML構文チェック FAIL」

**原因**: YAMLのインデントが壊れているか、特殊文字が正しくエスケープされていない。

**よくある原因と対処**:

1. **タブ文字がある** → YAMLはスペースのみ。タブを2スペースに変換する
2. **インデントがずれた** → 階層ごとに2スペースで統一する
3. **コロンの後ろにスペースがない** → `key:value` → `key: value`
4. **日本語テキストにクォートが必要** → 特殊文字が含まれる場合は `"..."` または `|` を使う

```yaml
# ❌ 悪い例
text: テスト: 確認用テキスト

# ✅ 良い例
text: "テスト: 確認用テキスト"
# または
text: |
  テスト: 確認用テキスト
```

---

## Difyインポートエラー編

### ❌ 「インポートに失敗しました」（Dify画面）

**チェックリスト**:
1. `validate-dsl.sh` を通してPASSしているか
2. `version: 0.6.0` になっているか（古いバージョンは不可）
3. `kind: app` が存在するか
4. `app.mode` が `advanced-chat` または `workflow` になっているか

---

### ❌ 「ノードが表示されない・つながっていない」（Difyエディタ上）

**原因**: `position` の値がすべて同じ（0,0）になっている。

**対処法**: 各ノードの `position` を変えて見やすく配置する：
```yaml
# startノード
position:
  x: 0
  y: 200

# 次のノード
position:
  x: 300
  y: 200

# さらに次のノード
position:
  x: 600
  y: 200
```

---

## スクリプト実行エラー編

### ❌ 「./scripts/validate-dsl.sh: Permission denied」

```bash
chmod +x scripts/*.sh
```

### ❌ 「python3: command not found」

Python 3.8以上をインストールしてください：
- Mac: `brew install python3`
- Ubuntu: `sudo apt-get install python3`

### ❌ 「yamllint: command not found」

```bash
./scripts/install-tools.sh
# または
pip install yamllint
```

### ❌ 「ModuleNotFoundError: No module named 'yaml'」

```bash
pip install pyyaml
# または
pip3 install pyyaml
```
