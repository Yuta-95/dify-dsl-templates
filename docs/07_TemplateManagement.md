# テンプレ更新・新規追加手順

---

## 既存テンプレを改善する

### 手順

```bash
# 1. 現行バージョンをコピー（バージョン番号を上げる）
cp templates/housing-loan/housing-loan-v1.0.0.yaml \
   templates/housing-loan/housing-loan-v1.1.0.yaml

# 2. 新バージョンを編集

# 3. 検証
./scripts/validate-dsl.sh templates/housing-loan/housing-loan-v1.1.0.yaml

# 4. Difyで実際に動作確認

# 5. Gitにコミット
git add templates/housing-loan/housing-loan-v1.1.0.yaml
git commit -m "feat: housing-loan v1.1.0 - フェーズ2の質問を追加"
git push
```

### 旧バージョンの扱い

- 旧バージョンは**削除しない**（いつでも戻れるように保管）
- README.mdの「推奨バージョン」だけ更新する

---

## 新しい業界テンプレを追加する

### 手順

1. **ディレクトリを作成**
```bash
mkdir -p templates/new-industry
```

2. **ベーステンプレからコピー**
```bash
cp templates/base/workflow-base-v1.0.0.yaml \
   templates/new-industry/new-industry-v1.0.0.yaml
```

3. **テンプレを業界に合わせてカスタマイズ**
   - `app.name` を変更
   - `app.description` を変更
   - `conversation_variables` に必要なスロット変数を追加
   - `llm` ノードのsystem promptを業界向けに書き換え
   - `code` ノードの抽出キーを業界に合わせる

4. **スキーマを追加（オプション）**
```bash
cp schemas/dify-workflow.minpaku.schema.json \
   schemas/dify-workflow.new-industry.schema.json
# スキーマファイルの $id と title を更新する
```

5. **検証**
```bash
./scripts/validate-dsl.sh templates/new-industry/new-industry-v1.0.0.yaml
```

6. **CHANGELOG.md を更新**
```markdown
## [v1.x.0] - YYYY-MM-DD
### Added
- new-industry テンプレを追加
```

7. **コミット**
```bash
git add templates/new-industry/ schemas/
git commit -m "feat: new-industry テンプレ v1.0.0 を追加"
git push
```

---

## CHANGELOG.md の書き方

```markdown
## [v1.2.0] - 2025-04-01
### Added
- marriage-consultation テンプレ v1.0.0 を追加

### Changed
- housing-loan v1.1.0: Phase2のスロット項目を拡充

### Fixed
- minpaku v1.0.1: 日付パースのバグを修正

### Deprecated
- housing-loan v1.0.0 は非推奨（v1.1.0 を使用してください）
```
