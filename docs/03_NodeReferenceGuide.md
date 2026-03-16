# Dify ノード種別リファレンスガイド

Dify v0.6.0 で使用できるノード種別と、その設定値の説明。

---

## ノード共通フィールド

```yaml
- data:
    type: <ノード種別>     # 必須
    title: "ノードの表示名"  # 必須
    selected: false        # 通常false固定
  id: "一意のノードID"      # 必須（英数字・ハイフン推奨）
  type: custom             # 必須（常にcustom）
  position:
    x: 300
    y: 200
  width: 242               # 推奨値
  height: 73               # ノード種別によって変わる
  sourcePosition: right
  targetPosition: left
```

---

## start（開始ノード）

ワークフローの起点。**必須・1つだけ**。

```yaml
data:
  type: start
  title: ユーザー入力
  variables: []  # カスタム入力変数（なければ空配列）
```

---

## llm（LLM応答）

ChatGPT等のAIモデルにテキストを送信し、応答を取得する。

```yaml
data:
  type: llm
  title: LLM応答
  model:
    name: gpt-4o-mini           # モデル名
    provider: langgenius/openai/openai
    mode: chat                  # chat / completion
    completion_params:
      temperature: 0.7          # 0.0〜2.0（低い=正確、高い=創造的）
  prompt_template:
  - id: system-prompt-001
    role: system                # system / user / assistant
    text: |
      システムプロンプトをここに記述
  memory:
    enabled: true               # 会話履歴を保持するか
    window:
      enabled: false
      size: 10                  # 保持するターン数
  context:
    enabled: false
    variable_selector: []       # Knowledge Base参照時に使用
  variables: []
  vision:
    enabled: false
```

**出力変数**: `{{#ノードID.text#}}`

---

## code（コード実行）

Python3 コードを実行する。JSON変換・計算・条件判定に使う。

```yaml
data:
  type: code
  title: コード処理
  code_language: python3
  code: |
    import json
    def main(input_var: str) -> dict:
        # 処理内容
        result = input_var.upper()
        return {"output": result}
  variables:
  - value_selector:
    - previous-node-id
    - text
    variable: input_var        # main()の引数名と一致させる
  outputs:
    output:
      children: null
      type: string
```

**出力変数**: `{{#ノードID.output_key#}}`

---

## if-else（条件分岐）

条件によって処理を分岐する。

```yaml
data:
  type: if-else
  title: 条件判定
  cases:
  - case_id: case-true          # エッジのsourceHandleと一致させる
    conditions:
    - id: cond-001
      comparison_operator: is   # 比較演算子（下記参照）
      value: 'expected_value'
      varType: string
      variable_selector:
      - node-id
      - variable_name
    logical_operator: and       # and / or
```

**比較演算子一覧**:
| 演算子 | 意味 |
|---|---|
| `is` | 完全一致 |
| `is not` | 不一致 |
| `contains` | 含む |
| `not contains` | 含まない |
| `is empty` | 空 |
| `is not empty` | 空でない |
| `>` / `<` / `>=` / `<=` | 数値比較 |

**エッジ接続**: case_id または `'false'`（elseブランチ）をsourceHandleに指定。

---

## assigner（変数代入）

会話変数（`conversation_variables`）に値をセットする。

```yaml
data:
  type: assigner
  title: 変数保存
  actions:
  - operation: set              # set / clear / append
    value: '{{#node-id.output#}}'
    variable_selector:
    - conversation
    - cv_variable_name          # conversation_variablesで定義した変数名
```

---

## answer（回答出力）

ユーザーへの最終回答を出力する。advanced-chatモードで使用。

```yaml
data:
  type: answer
  title: 回答出力
  answer: '{{#llm-node-id.text#}}'  # 表示するテキスト
  variables: []
```

---

## end（終了ノード）

workflowモード（非advanced-chat）で使用する終了ノード。

```yaml
data:
  type: end
  title: 終了
  outputs:
  - value_selector:
    - previous-node-id
    - output
    variable: result
```

---

## エッジ（接続）フィールド

```yaml
edges:
- id: "source-node-id-source-target-node-id-target"  # 命名規則
  source: "source-node-id"
  sourceHandle: source          # 通常は "source"、if-elseはcase_idまたは"false"
  target: "target-node-id"
  targetHandle: target          # 通常は "target"
  type: custom                  # 常にcustom
  selected: false
  zIndex: 0
  data:
    isInLoop: false
    sourceType: start           # ソースノードのtype
    targetType: llm             # ターゲットノードのtype
```
