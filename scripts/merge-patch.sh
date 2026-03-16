#!/usr/bin/env bash
# ============================================================
# merge-patch.sh
# 生成AIが出力した差分パッチ（JSON）をDify DSL YAMLに適用する
#
# 使用例:
#   ./scripts/merge-patch.sh \
#     templates/line-concierge/line-concierge-v1.0.0.yaml \
#     patches/examples/patch-prompt-update.json \
#     > line-concierge-v1.0.1.yaml
#
# パッチファイル形式:
#   {
#     "operations": [
#       { "path": "workflow.graph.nodes[0].data.title", "op": "replace", "value": "新しいタイトル" }
#     ]
#   }
# ============================================================
set -uo pipefail

if [ $# -lt 2 ]; then
    echo "使用方法: $0 <DSLファイル> <パッチファイル> [出力ファイル]"
    echo "例)      $0 templates/base/workflow-base-v1.0.0.yaml patches/my-patch.json > output.yaml"
    exit 1
fi

DSL_FILE="$1"
PATCH_FILE="$2"
OUTPUT_FILE="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# 絶対パス変換
[[ "$DSL_FILE" != /* ]] && DSL_FILE="$ROOT_DIR/$DSL_FILE"
[[ "$PATCH_FILE" != /* ]] && PATCH_FILE="$ROOT_DIR/$PATCH_FILE"

if [ ! -f "$DSL_FILE" ]; then
    echo "❌ DSLファイルが見つかりません: $DSL_FILE" >&2
    exit 1
fi

if [ ! -f "$PATCH_FILE" ]; then
    echo "❌ パッチファイルが見つかりません: $PATCH_FILE" >&2
    exit 1
fi

# Python でパッチを適用
RESULT=$(python3 - "$DSL_FILE" "$PATCH_FILE" <<'PYEOF'
import sys
import yaml
import json

dsl_path = sys.argv[1]
patch_path = sys.argv[2]

# DSL読み込み
with open(dsl_path, 'r', encoding='utf-8') as f:
    dsl = yaml.safe_load(f)

# パッチ読み込み
with open(patch_path, 'r', encoding='utf-8') as f:
    patch = json.load(f)

operations = patch.get('operations', [])

def set_nested(obj, path_str, value):
    """
    'workflow.graph.nodes[0].data.title' のようなパス文字列で値をセットする
    """
    import re
    parts = []
    for segment in path_str.split('.'):
        m = re.match(r'^(\w+)\[(\d+)\]$', segment)
        if m:
            parts.append(m.group(1))
            parts.append(int(m.group(2)))
        else:
            parts.append(segment)

    cursor = obj
    for i, part in enumerate(parts[:-1]):
        if isinstance(part, int):
            cursor = cursor[part]
        else:
            cursor = cursor[part]

    last = parts[-1]
    if isinstance(last, int):
        cursor[last] = value
    else:
        cursor[last] = value

applied = 0
errors = []

for op in operations:
    try:
        operation = op.get('op', 'replace')
        path = op.get('path', '')
        value = op.get('value')

        if operation == 'replace':
            set_nested(dsl, path, value)
            applied += 1
        elif operation == 'add':
            set_nested(dsl, path, value)
            applied += 1
        else:
            errors.append(f"未対応のoperation: {operation}")
    except Exception as e:
        errors.append(f"パス '{op.get('path')}' の適用に失敗: {e}")

if errors:
    for e in errors:
        print(f"# ERROR: {e}", file=sys.stderr)

# YAML出力
print(yaml.dump(dsl, allow_unicode=True, sort_keys=False, default_flow_style=False))
print(f"# {applied}件のパッチを適用しました", file=sys.stderr)
PYEOF
)

if [ -n "$OUTPUT_FILE" ]; then
    echo "$RESULT" > "$OUTPUT_FILE"
    echo "✅ パッチ適用完了: $OUTPUT_FILE" >&2
else
    echo "$RESULT"
fi
