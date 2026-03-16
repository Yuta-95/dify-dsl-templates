#!/usr/bin/env python3
"""
detect_unused_nodes.py
Dify DSL v0.6.0 の未使用・孤立ノードを検出して警告する

「未使用」の定義:
  - edgesのsource/targetに一切登場しないノード
  - ただし start/end/answer タイプは除外

使用例:
  python3 scripts/detect_unused_nodes.py templates/base/workflow-base-v1.0.0.yaml
"""

import sys
import yaml


def load_dsl(path: str) -> dict:
    with open(path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def detect_unused(path: str) -> list[dict]:
    try:
        data = load_dsl(path)
    except Exception as e:
        print(f"YAMLパースエラー: {e}")
        sys.exit(1)

    graph_data = data.get('workflow', {}).get('graph', {})
    nodes = graph_data.get('nodes', [])
    edges = graph_data.get('edges', [])

    # エッジに登場するノードIDセット
    edge_nodes = set()
    for edge in edges:
        if edge.get('source'):
            edge_nodes.add(edge['source'])
        if edge.get('target'):
            edge_nodes.add(edge['target'])

    # 未使用ノード検出
    exempt_types = {'start', 'end', 'answer'}
    unused = []

    for node in nodes:
        nid = node['id']
        ntype = node.get('data', {}).get('type', 'unknown')
        ntitle = node.get('data', {}).get('title', nid)

        if ntype in exempt_types:
            continue

        if nid not in edge_nodes:
            unused.append({
                'id': nid,
                'type': ntype,
                'title': ntitle
            })

    return unused


def main():
    if len(sys.argv) < 2:
        print("使用方法: python3 detect_unused_nodes.py <DSLファイル>")
        sys.exit(1)

    unused = detect_unused(sys.argv[1])

    if unused:
        print(f"未使用ノードが {len(unused)} 件あります（削除を検討してください）:")
        for n in unused:
            print(f"  ⚠️  {n['title']} (id={n['id']}, type={n['type']})")
        # 未使用ノードは警告のみ（Exit Code 0）
        sys.exit(0)
    else:
        print("未使用ノードなし")
        sys.exit(0)


if __name__ == '__main__':
    main()
