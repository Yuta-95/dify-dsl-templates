# Git操作ガイド（非エンジニア向け）

---

## 初回セットアップ

### GitHub Desktopを使う場合（推奨）

1. [GitHub Desktop](https://desktop.github.com/) をインストール
2. GitHubアカウントでサインイン
3. 「Clone Repository」→ `dify-dsl-templates` を選択
4. ローカルフォルダを指定して「Clone」

### コマンドラインを使う場合

```bash
git clone https://github.com/[あなたのアカウント]/dify-dsl-templates.git
cd dify-dsl-templates
```

---

## 日常的な使い方

### 新しいワークフローを追加する

```bash
# 1. テンプレからコピー
cp templates/housing-loan/housing-loan-v1.0.0.yaml \
   templates/housing-loan/housing-loan-v1.1.0.yaml

# 2. 修正する（エディタで開いて編集）

# 3. 検証する
./scripts/validate-dsl.sh templates/housing-loan/housing-loan-v1.1.0.yaml

# 4. Gitに保存
git add templates/housing-loan/housing-loan-v1.1.0.yaml
git commit -m "feat: 住宅ローン v1.1.0 プロンプト改善"
git push
```

### GitHub Desktopの場合

1. ファイルを修正・保存する
2. GitHub Desktopを開く
3. 左側に変更ファイルが表示される
4. 下部の「Summary」に変更内容を入力（例: `プロンプト改善`）
5. 「Commit to main」をクリック
6. 右上の「Push origin」をクリック

---

## バージョン管理の命名規則

```
templates/
└── housing-loan/
    ├── housing-loan-v1.0.0.yaml   # 初版
    ├── housing-loan-v1.1.0.yaml   # マイナーアップデート（機能追加）
    ├── housing-loan-v1.1.1.yaml   # パッチ（バグ修正）
    └── housing-loan-v2.0.0.yaml   # メジャーアップデート（大幅変更）
```

**バージョン番号のルール（セマンティックバージョニング）**:

| バージョン | 変更内容 | 例 |
|---|---|---|
| `v1.0.0 → v2.0.0` | ノード構成が大きく変わった | フロー全体を再設計 |
| `v1.0.0 → v1.1.0` | 機能を追加した | スロット項目を増やした |
| `v1.0.0 → v1.0.1` | 小さな修正 | プロンプトの誤字修正 |

---

## 過去のバージョンに戻す

### GitHub Desktopの場合

1. 「History」タブを開く
2. 戻したいコミットを右クリック
3. 「Revert Changes in Commit」

### コマンドラインの場合

```bash
# 変更履歴を確認
git log --oneline templates/housing-loan/housing-loan-v1.0.0.yaml

# 特定バージョンに戻す
git checkout abc1234 -- templates/housing-loan/housing-loan-v1.0.0.yaml
```

---

## チームでの共同作業

### ブランチを使う（推奨）

```bash
# 新しいブランチを作成（feature/自分の作業名）
git checkout -b feature/minpaku-v2-redesign

# 作業後、mainにマージ
git checkout main
git merge feature/minpaku-v2-redesign
```

### コンフリクト（競合）が起きたら

同じファイルを複数人が同時に編集すると競合が起きる。
GitHub Desktopでは「Resolve Conflicts」ボタンが表示される。
困ったらエンジニアに相談。
