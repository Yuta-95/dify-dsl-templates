#!/usr/bin/env bash
# ============================================================
# validate-dsl.sh
# Dify DSL (v0.6.0) ワンコマンド検証スクリプト
#
# 使用例:
#   ./scripts/validate-dsl.sh templates/base/workflow-base-v1.0.0.yaml
#   ./scripts/validate-dsl.sh templates/line-concierge/line-concierge-v1.0.0.yaml
#
# Exit Code: 0 = 全PASS / 1 = 1件以上FAIL
# ============================================================
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# ── 引数チェック ────────────────────────────────────────
if [ $# -eq 0 ]; then
    echo "使用方法: $0 <DSLファイルパス>"
    echo "例)      $0 templates/base/workflow-base-v1.0.0.yaml"
    exit 1
fi

DSL_FILE="$1"

# 絶対パス変換
if [[ "$DSL_FILE" != /* ]]; then
    DSL_FILE="$ROOT_DIR/$DSL_FILE"
fi

if [ ! -f "$DSL_FILE" ]; then
    echo "❌ ファイルが見つかりません: $DSL_FILE"
    exit 1
fi

echo ""
echo "=================================================="
echo "  Dify DSL 検証: $(basename "$DSL_FILE")"
echo "=================================================="
echo ""

PASS=0
FAIL=0
WARN=0

# ── ヘルパー関数 ────────────────────────────────────────
pass() { echo "✅ $1 ... PASS"; PASS=$((PASS + 1)); }
fail() { echo "❌ $1 ... FAIL: $2"; FAIL=$((FAIL + 1)); }
warn() { echo "⚠️  $1 ... 警告: $2"; WARN=$((WARN + 1)); }

# ────────────────────────────────────────────────────────
# 検証 1: YAML 構文チェック（yamllint）
# ────────────────────────────────────────────────────────
echo "🔍 1. YAML構文チェック..."
if command -v yamllint &>/dev/null; then
    # リポジトリルートの .yamllint 設定を使用
    YAMLLINT_CONFIG="$ROOT_DIR/.yamllint"
    if [ -f "$YAMLLINT_CONFIG" ]; then
        YAMLLINT_CMD="yamllint -c $YAMLLINT_CONFIG"
    else
        YAMLLINT_CMD="yamllint -d relaxed"
    fi
    YAMLLINT_OUT=$($YAMLLINT_CMD "$DSL_FILE" 2>&1)
    ERROR_COUNT=$(echo "$YAMLLINT_OUT" | grep -c " error " || true)
    if [ "$ERROR_COUNT" -eq 0 ]; then
        pass "YAML構文チェック"
    else
        FIRST_ERRORS=$(echo "$YAMLLINT_OUT" | grep " error " | head -3)
        fail "YAML構文チェック" "$FIRST_ERRORS"
    fi
else
    warn "YAML構文チェック" "yamllint が未インストール → ./scripts/install-tools.sh を実行してください"
fi

# ────────────────────────────────────────────────────────
# 検証 2: Dify DSL 必須フィールド確認（Python）
# ────────────────────────────────────────────────────────
echo "🔍 2. 必須フィールド確認..."
REQUIRED_CHECK=$(python3 - "$DSL_FILE" <<'PYEOF'
import sys, yaml

path = sys.argv[1]
try:
    with open(path, 'r', encoding='utf-8') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print(f"FAIL: YAMLパースエラー: {e}")
    sys.exit(1)

errors = []

# トップレベル必須フィールド
for field in ['app', 'kind', 'version', 'workflow']:
    if field not in data:
        errors.append(f"必須フィールド '{field}' が存在しません")

if 'app' in data:
    for field in ['name', 'mode']:
        if field not in data.get('app', {}):
            errors.append(f"app.{field} が存在しません")

if 'workflow' in data:
    wf = data['workflow']
    if 'graph' not in wf:
        errors.append("workflow.graph が存在しません")
    else:
        graph = wf['graph']
        if 'nodes' not in graph:
            errors.append("workflow.graph.nodes が存在しません")
        if 'edges' not in graph:
            errors.append("workflow.graph.edges が存在しません")

        # nodes 最小チェック
        nodes = graph.get('nodes', [])
        if len(nodes) < 2:
            errors.append(f"ノード数が少なすぎます（{len(nodes)}個、最低2個必要）")

        # startノード確認
        node_types = [n.get('data', {}).get('type') for n in nodes]
        if 'start' not in node_types:
            errors.append("'start' タイプのノードが存在しません")

if errors:
    for e in errors:
        print(f"FAIL: {e}")
    sys.exit(1)
else:
    print(f"PASS: nodes={len(data.get('workflow',{}).get('graph',{}).get('nodes',[]))}, edges={len(data.get('workflow',{}).get('graph',{}).get('edges',[]))}")
    sys.exit(0)
PYEOF
)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    pass "必須フィールド確認 ($REQUIRED_CHECK)"
else
    fail "必須フィールド確認" "$REQUIRED_CHECK"
fi

# ────────────────────────────────────────────────────────
# 検証 3: ノード接続チェック
# ────────────────────────────────────────────────────────
echo "🔍 3. ノード接続チェック..."
NODE_CHECK=$(python3 "$SCRIPT_DIR/check_node_connectivity.py" "$DSL_FILE" 2>&1)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    pass "ノード接続チェック"
else
    # 警告のみで続行
    warn "ノード接続チェック" "$NODE_CHECK"
fi

# ────────────────────────────────────────────────────────
# 検証 4: 循環参照チェック
# ────────────────────────────────────────────────────────
echo "🔍 4. 循環参照チェック..."
CIRC_CHECK=$(python3 "$SCRIPT_DIR/check_circular_references.py" "$DSL_FILE" 2>&1)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    pass "循環参照チェック"
else
    fail "循環参照チェック" "$CIRC_CHECK"
fi

# ────────────────────────────────────────────────────────
# 検証 5: 未使用ノード検出
# ────────────────────────────────────────────────────────
echo "🔍 5. 未使用ノード検出..."
UNUSED_CHECK=$(python3 "$SCRIPT_DIR/detect_unused_nodes.py" "$DSL_FILE" 2>&1)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    if [ -z "$UNUSED_CHECK" ]; then
        pass "未使用ノード検出（未使用ノードなし）"
    else
        warn "未使用ノード検出" "$UNUSED_CHECK"
    fi
fi

# ────────────────────────────────────────────────────────
# 結果サマリー
# ────────────────────────────────────────────────────────
echo ""
echo "=================================================="
echo "  📊 検証結果サマリー"
echo "    PASS: $PASS  /  WARN: $WARN  /  FAIL: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo "  ✅ すべての必須検証に合格しました"
    if [ $WARN -gt 0 ]; then
        echo "  ⚠️  警告が ${WARN} 件あります（インポートには影響しません）"
    fi
    echo "=================================================="
    echo ""
    exit 0
else
    echo "  ❌ 検証失敗: ${FAIL} 件のエラーを修正してください"
    echo "  → docs/06_TroubleshootingGuide.md を参照"
    echo "=================================================="
    echo ""
    exit 1
fi
