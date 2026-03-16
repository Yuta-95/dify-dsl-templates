#!/usr/bin/env python3
"""
check_node_connectivity.py
Dify DSL v0.6.0 のノード接続を検証する

チェック内容:
  1. 存在しないノードへのエッジ参照
  2. 孤立ノード（edgesに一切登場しないノード）
  3. デッドエンド（出力エッジのないノード、answerとendを除く）

使用例:
  python3 scripts/check_node_connectivity.py templates/base/workflow-base-v1.0.0.yaml
"""

import sys
import yaml


def load_dsl(path: str) -> dict:
    with open(path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def check_connectivity(path: str) -> list[str]:
    try:
        data = load_dsl(path)
    except Exception as e:
        return [f"YAMLパースエラー: {e}"]

    graph = data.get('workflow', {}).get('graph', {})
    nodes = graph.get('nodes', [])
    edges = graph.get('edges', [])

    node_ids = {n['id'] for n in nodes}
    node_types = {n['id']: n.get('data', {}).get('type', '') for n in nodes}

    errors = []

    # ── 1. 存在しないノードへのエッジ参照 ──────────────────
    for edge in edges:
        src = edge.get('source', '')
        tgt = edge.get('target', '')
        if src and src not in node_ids:
            errors.append(f"エッジの source ノード '{src}' が nodes に存在しません")
        if tgt and tgt not in node_ids:
            errors.append(f"エッジの target ノード '{tgt}' が nodes に存在しません")

    # エッジに登場するノードIDセット
    edge_sources = {e.get('source') for e in edges if e.get('source')}
    edge_targets = {e.get('target') for e in edges if e.get('target')}
    referenced_nodes = edge_sources | edge_targets

    # ── 2. 孤立ノード（edgesに一切登場しない） ─────────────
    terminal_types = {'start', 'end', 'answer'}
    for nid in node_ids:
        ntype = node_types.get(nid, '')
        if nid not in referenced_nodes and ntype not in terminal_types:
            # startノードは出力だけなので target には現れなくてOK
            if ntype != 'start':
                errors.append(f"孤立ノード: '{nid}' (type={ntype}) はどのエッジにも接続されていません")

    # ── 3. デッドエンド（出力エッジのないノード） ───────────
    # answer/end は出力エッジを持たなくてOK
    no_output_ok = {'end', 'answer'}
    for nid in node_ids:
        ntype = node_types.get(nid, '')
        if ntype in no_output_ok:
            continue
        if nid not in edge_sources:
            errors.append(f"デッドエンド: '{nid}' (type={ntype}) に出力エッジがありません")

    return errors


def main():
    if len(sys.argv) < 2:
        print("使用方法: python3 check_node_connectivity.py <DSLファイル>")
        sys.exit(1)

    errors = check_connectivity(sys.argv[1])

    if errors:
        for e in errors:
            print(e)
        sys.exit(1)
    else:
        print("接続チェック: 問題なし")
        sys.exit(0)


if __name__ == '__main__':
    main()
