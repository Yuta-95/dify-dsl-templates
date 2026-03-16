# 5分で始める Dify DSL 開発

**対象**: 非エンジニア（営業・DX担当・事業責任者）
**所要時間**: 5分

---

## このリポジトリでできること

```
新しい案件の Dify ワークフローを
テンプレからコピー → プロンプト修正 → 検証 → Difyにインポート
で、ゼロから作らずに品質を担保して高速開発できる。
```

---

## ステップ1：テンプレを選ぶ（1分）

| やりたいこと | 使うテンプレ |
|---|---|
| LINE経由の住宅ローン相談 | `templates/line-concierge/line-concierge-phaseflow-v1.0.0.yaml` |
| 住宅ローン相談（シンプル版） | `templates/housing-loan/housing-loan-v1.0.0.yaml` |
| 民泊の問い合わせ・予約受付 | `templates/minpaku/minpaku-v1.0.0.yaml` |
| 結婚相談所の受付 | `templates/marriage-consultation/marriage-consultation-v1.0.0.yaml` |
| 何もないところから作る | `templates/base/workflow-base-v1.0.0.yaml` |

---

## ステップ2：ファイルをコピーする（30秒）

```bash
# 例：住宅ローン相談をベースに新しいプロジェクトを作る
cp templates/housing-loan/housing-loan-v1.0.0.yaml \
   my-new-project-v1.0.0.yaml
```

Macの場合はFinder上でファイルをコピーするだけでもOK。

---

## ステップ3：プロンプトを修正する（3分）

コピーしたファイルをエディタで開いて、`prompt_template` の部分だけ変更する。

**修正する場所の見つけ方**:
```yaml
# ↓ ここを探す
prompt_template:
- id: xxxx
  role: system
  text: |
    ← この中のテキストを自分の案件用に書き換える
```

**修正例（住宅ローン → 自動車ローンに変える場合）**:
```yaml
# 修正前
text: |
  住宅ローン相談サービスの受付AIです。

# 修正後
text: |
  自動車ローン相談サービスの受付AIです。
  ユーザーから車種・購入金額・頭金を確認してください。
```

---

## ステップ4：検証する（30秒）

```bash
./scripts/validate-dsl.sh my-new-project-v1.0.0.yaml
```

**成功時の出力**:
```
✅ 1. YAML構文チェック ... PASS
✅ 2. 必須フィールド確認 ... PASS
✅ 3. ノード接続チェック ... PASS
✅ 4. 循環参照チェック ... PASS
✅ すべての必須検証に合格しました
```

エラーが出たら → `docs/06_TroubleshootingGuide.md` を確認。

---

## ステップ5：Difyにインポートする（1分）

1. Dify管理画面 → 「アプリを作成」
2. 「DSLファイルからインポート」を選択
3. `my-new-project-v1.0.0.yaml` をアップロード
4. インポート完了 → テスト実行

---

## ステップ6：Gitに保存する（30秒）

```bash
# ファイルをステージング
git add my-new-project-v1.0.0.yaml

# コミット
git commit -m "feat: 新案件 my-new-project v1.0.0 を追加"

# GitHubに反映
git push
```

GitHub Desktopを使う場合は右クリック → 「コミット」→「プッシュ」でOK。

---

## よくある質問

**Q: scriptが動かない**
A: まず `./scripts/install-tools.sh` を実行してください。

**Q: Difyにインポートしたらエラーになる**
A: `validate-dsl.sh` を通してからインポートしてください。検証PASSすればほぼインポートできます。

**Q: テンプレのノード構成を変えたい**
A: `docs/03_NodeReferenceGuide.md` を参照してください。
