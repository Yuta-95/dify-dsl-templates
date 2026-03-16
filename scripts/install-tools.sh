#!/usr/bin/env bash
# ============================================================
# install-tools.sh
# Dify DSL 検証に必要なツールを自動インストールする
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=================================================="
echo "  Dify DSL 検証ツール インストーラー"
echo "=================================================="
echo ""

# OS判定
OS="$(uname -s)"
echo "🔍 OS 検出: $OS"
echo ""

# ── Python 確認 ──────────────────────────────────────────
echo "📦 [1/4] Python パッケージをインストール中..."
if command -v pip3 &>/dev/null; then
    PIP=pip3
elif command -v pip &>/dev/null; then
    PIP=pip
else
    echo "❌ pip が見つかりません。Python 3.8+ をインストールしてください。"
    exit 1
fi

$PIP install --quiet --break-system-packages \
    pyyaml \
    jsonschema \
    networkx \
    yamllint 2>/dev/null || \
$PIP install --quiet \
    pyyaml \
    jsonschema \
    networkx \
    yamllint
echo "✅ Python パッケージ インストール完了"
echo ""

# ── Node.js / npm 確認 ───────────────────────────────────
echo "📦 [2/4] Node.js パッケージをインストール中..."
if command -v npm &>/dev/null; then
    cd "$ROOT_DIR"
    npm install --silent 2>/dev/null || true
    echo "✅ Node.js パッケージ インストール完了"
else
    echo "⚠️  npm が見つかりません。ajv-cli のインストールをスキップします。"
    echo "   → Node.js 18+ をインストール後、'npm install' を実行してください。"
fi
echo ""

# ── jq 確認 ──────────────────────────────────────────────
echo "📦 [3/4] jq の確認..."
if command -v jq &>/dev/null; then
    echo "✅ jq は既にインストール済み ($(jq --version))"
else
    echo "⚠️  jq が見つかりません。インストールを試みます..."
    if [ "$OS" = "Darwin" ]; then
        brew install jq 2>/dev/null && echo "✅ jq インストール完了" || echo "⚠️  brew で jq をインストールしてください: brew install jq"
    elif [ "$OS" = "Linux" ]; then
        sudo apt-get install -y jq 2>/dev/null || \
        sudo yum install -y jq 2>/dev/null || \
        echo "⚠️  パッケージマネージャで jq をインストールしてください"
    fi
fi
echo ""

# ── yamllint 確認 ────────────────────────────────────────
echo "📦 [4/4] yamllint の確認..."
if command -v yamllint &>/dev/null; then
    echo "✅ yamllint は既にインストール済み"
else
    echo "⚠️  yamllint が見つかりません。pip でインストールしてください: pip install yamllint"
fi
echo ""

echo "=================================================="
echo "  ✅ インストール完了"
echo ""
echo "  次のステップ:"
echo "  ./scripts/validate-dsl.sh templates/base/workflow-base-v1.0.0.yaml"
echo "=================================================="
