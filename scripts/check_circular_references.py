#!/usr/bin/env python3
"""
check_circular_references.py
Dify DSL v0.6.0 のワークフロー内の循環参照（無限ループ）を検出する

アルゴリズム: DFS (深さ優先探索) によるサイクル検出

使用例:
  python3 scripts/check_circular_references.py templates/base/workflow-base-v1.0.0.yaml
"""

import sys
import yaml
from collections import defaultdict


def load_dsl(path: str) -> dict:
    with open(path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def detect_cycles(path: str) -> list[str]:
    try:
        data = load_dsl(path)
    except Exception as e:
        return [f"YAMLパースエラー: {e}"]

    graph_data = data.get('workflow', {}).get('graph', {})
    nodes = graph_data.get('nodes', [])
    edges = graph_data.get('edges', [])

    # 隣接リスト構築
    adj: dict[str, list[str]] = defaultdict(list)
    for edge in edges:
        src = edge.get('source', '')
        tgt = edge.get('target', '')
        if src and tgt:
            adj[src].append(tgt)

    node_ids = [n['id'] for n in nodes]

    # DFS でサイクル検出
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {nid: WHITE for nid in node_ids}
    parent = {nid: None for nid in node_ids}
    cycles = []

    def dfs(node: str, path: list[str]) -> None:
        color[node] = GRAY
        path.append(node)

        for neighbor in adj.get(node, []):
            if neighbor not in color:
                continue
            if color[neighbor] == GRAY:
                # サイクル発見：パスから循環部分を抽出
                cycle_start = path.index(neighbor)
                cycle = path[cycle_start:] + [neighbor]
                cycles.append(" -> ".join(cycle))
            elif color[neighbor] == WHITE:
                dfs(neighbor, path)

        path.pop()
        color[node] = BLACK

    for nid in node_ids:
        if color[nid] == WHITE:
            dfs(nid, [])

    return cycles


def main():
    if len(sys.argv) < 2:
        print("使用方法: python3 check_circular_references.py <DSLファイル>")
        sys.exit(1)

    cycles = detect_cycles(sys.argv[1])

    if cycles:
        print("循環参照を検出しました:")
        for c in cycles:
            print(f"  🔄 {c}")
        sys.exit(1)
    else:
        print("循環参照チェック: 問題なし")
        sys.exit(0)


if __name__ == '__main__':
    main()
