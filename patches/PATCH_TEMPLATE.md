# パッチ作成ガイド

差分パッチを使うと、DSL全文を書き換えずに特定の箇所だけ変更できる。

## パッチファイルの形式

```json
{
  "_comment": "このパッチの説明",
  "operations": [
    {
      "path": "変更対象のパス（ドット区切り）",
      "op": "操作種別",
      "value": "新しい値"
    }
  ]
}
```

## 操作種別

| op | 意味 |
|---|---|
| `replace` | 既存の値を置き換える |
| `add` | 新しいキーを追加する |

## パスの書き方

```
app.name                                    → app.name フィールド
workflow.graph.nodes[0].data.title         → 1番目のノードのtitle
workflow.graph.nodes[2].data.prompt_template[0].text → 3番目のノードのsystemプロンプト
```

## 適用方法

```bash
./scripts/merge-patch.sh \
  templates/housing-loan/housing-loan-v1.0.0.yaml \
  patches/my-patch.json \
  templates/housing-loan/housing-loan-v1.0.1.yaml
```

## ヒント

- パッチを適用した後は必ず `validate-dsl.sh` で検証すること
- パッチファイルはGitで管理すると変更履歴が追跡できる
- 大きな変更はパッチよりも新バージョンのテンプレを作る方が推奨
