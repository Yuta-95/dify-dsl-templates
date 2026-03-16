# よくある修正パターン集

---

## パターン1：プロンプトを変更する（最もよく使う）

### 対象ノード
`type: llm` のノードの `prompt_template`

### Before
```yaml
- id: system-prompt-001
  role: system
  text: |
    住宅ローン相談サービスの受付AIです。
```

### After
```yaml
- id: system-prompt-001
  role: system
  text: |
    自動車ローン相談サービスの受付AIです。
    ユーザーから以下の情報を確認してください：
    - 購入希望車種
    - 購入金額
    - 頭金
    - 月々の支払い希望額
```

### パッチファイル形式
```json
{
  "operations": [
    {
      "path": "workflow.graph.nodes[4].data.prompt_template[0].text",
      "op": "replace",
      "value": "自動車ローン相談サービスの受付AIです。\n..."
    }
  ]
}
```

---

## パターン2：LLMモデルを変更する

### 対象
`model.name` と `model.provider`

```yaml
# Before: gpt-4o-mini
model:
  name: gpt-4o-mini
  provider: langgenius/openai/openai

# After: claude-3-haiku（Anthropic）
model:
  name: claude-3-haiku-20240307
  provider: langgenius/anthropic/anthropic
```

---

## パターン3：スロット抽出キーを増やす

### 対象
`code` タイプのノード / LLMのsystem prompt

### 手順
1. LLMの抽出プロンプトにキーを追加
2. codeノードのパース処理は特に変更不要（JSON全体を保存するため）

```yaml
# LLM system promptに追加
text: |
  【追加する抽出キー】
  - new_field: 新しい項目の説明
```

---

## パターン4：分岐条件を変える（if-elseノード）

### Before（空かどうかで分岐）
```yaml
cases:
- case_id: has-data
  conditions:
  - comparison_operator: is not empty
    variable_selector:
    - conversation
    - cv_state
```

### After（特定の値かどうかで分岐）
```yaml
cases:
- case_id: is-phase2
  conditions:
  - comparison_operator: is
    value: 'phase2'
    variable_selector:
    - conversation
    - cv_state
```

---

## パターン5：アプリ名・アイコンを変える

```yaml
# ファイル先頭のapp:セクションを修正
app:
  description: 新しいアプリの説明
  icon: 🏢   ← 絵文字を変更
  icon_background: '#D5F5F6'  ← 背景色を変更（16進数）
  name: 新しいアプリ名_v1.0.0
```

---

## パターン6：会話変数を追加する

```yaml
conversation_variables:
# 既存の変数...
- description: 新しい管理変数
  id: cv_new_var_001
  name: cv_new_variable
  selector:
  - conversation
  - cv_new_variable
  value: ''
  value_type: string  # string / number / boolean / object / array
```

---

## パターン7：ノードを追加する

新しいノードを追加する際は **edges も必ず更新** すること。

### 手順
1. `graph.nodes` に新ノードを追加
2. `graph.edges` に新しいエッジを追加（前のノード→新ノード、新ノード→次のノード）
3. `validate-dsl.sh` で検証

```yaml
# 1. nodesに追加
- data:
    title: 新しいノード
    type: code
    code: |
      def main(input: str) -> dict:
          return {"result": input}
    # ...
  id: new-node-001

# 2. edgesに追加（前のノードから）
- source: existing-node-prev
  target: new-node-001
  id: prev-to-new
  # ...

# 3. edgesに追加（新ノードから次へ）
- source: new-node-001
  target: existing-node-next
  id: new-to-next
  # ...
```
