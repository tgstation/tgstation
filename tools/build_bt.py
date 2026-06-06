#!/usr/bin/env python3
"""
Behavior tree JSON compiler/parser. Converts the .bt.json formated files
into a compacted and runtime-readable converted json format.

It does this by parsing all defines and replacing the defines in the json with their values. It also checks some specific macros like SECONDS, MINUTES and HOURS.

This lets us use defines in the JSON :D

Usage:
    python tools/build_bt.py [--repo-root PATH] [--check]

Options:
    --check     Verify that all generated files are up to date without writing anything.
                Exits with code 1 if any file differs. Used by CI.
"""

import ast
import json
import os
import re
import sys
import warnings
from pathlib import Path

# The time macros, so we can use them in JSON files
TIMING_SUBS = [
    (re.compile(r'\bHOURS\b'),   '*36000'),
    (re.compile(r'\bMINUTES\b'), '*600'),
    (re.compile(r'\bSECONDS\b'), '*10'),
]

# Matches any DM identifier; used for single-pass define substitution.
_IDENT_RE = re.compile(r'\b([A-Za-z_]\w*)\b')

# Shorthand for our nodes that never change, the others get subtyped, these in theory dont.
STATIC_NODES: dict[str, str] = {
    'selector': '/datum/bt_node/composite/selector',
    'sequence': '/datum/bt_node/composite/sequence',
    'parallel': '/datum/bt_node/composite/parallel',
    'subplan':  '/datum/bt_node/composite/subplan',
}

# Source JSON structural keys that are consumed/transformed during compilation.
_CONSUMED_KEYS = frozenset({'type', 'children', 'child', 'decorator', 'behavior', 'args', 'config', 'vars', 'subtype', 'dm_type', 'bindings'})



def parse_defines(repo_root: Path) -> dict:
    """
    Scan all .dm files under code/__DEFINES/ and resolve every #define to a
    Python int, float, or str value.

    Uses multi-pass resolution so that defines referencing other defines work
    regardless of file or declaration order.  Stops when a full pass makes no
    new progress (handles transitive references; cycles are silently skipped).
    """
    defines: dict = {
        'TRUE':  1,
        'FALSE': 0,
        'null':  None,
    }

    pending: list[tuple[str, str]] = []
    seen_names: set[str] = set(defines)
    defines_dir = repo_root / 'code'
    for fpath in sorted(defines_dir.rglob('*.dm')):
        for line in fpath.read_text(encoding='utf-8', errors='ignore').splitlines():
            line = line.strip()
            if not line.startswith('#define '):
                continue
            rest = line[len('#define '):]
            parts = rest.split(None, 1)
            if len(parts) < 2:
                continue
            name, raw = parts[0], parts[1].strip()
            raw = re.sub(r'\s*//.*$', '', raw).strip()
            if not raw or name in seen_names:
                continue  # value-less define or already seen (first wins)
            seen_names.add(name)
            pending.append((name, raw))

    while pending:
        resolved_this_pass = 0
        still_pending: list[tuple[str, str]] = []
        for name, raw in pending:
            value = _resolve_expr(raw, defines)
            if value is not None:
                defines[name] = value
                resolved_this_pass += 1
            else:
                still_pending.append((name, raw))
        pending = still_pending
        if resolved_this_pass == 0:
            break  # no new defines found

    return defines


def _resolve_expr(raw: str, defines: dict):
    """
    Try to resolve a raw define RHS string to a Python number or str.
    Returns None if the expression cannot be evaluated.
    """
    def _sub(m):
        name = m.group(1)
        if name not in defines:
            return name
        val = defines[name]
        if val is None:
            return 'None'
        if isinstance(val, str):
            return repr(val)
        if isinstance(val, (int, float)):
            return str(val)
        return name

    expr = _IDENT_RE.sub(_sub, raw)

    # Apply DM postfix timing operators
    for pattern, replacement in TIMING_SUBS:
        expr = pattern.sub(replacement, expr)

    expr = expr.strip()

    try:
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', SyntaxWarning)
            val = ast.literal_eval(expr)
        if isinstance(val, (int, float, str)):
            return val
        return None
    except Exception:
        pass

    try:
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', SyntaxWarning)
            val = eval(expr, {'__builtins__': {}}, {})  # noqa: S307
        if isinstance(val, (int, float)):
            return val
    except Exception:
        pass

    return None


def _split_list_args(inner: str) -> list[str]:
    """Split comma-separated args respecting nested parentheses."""
    args: list[str] = []
    depth = 0
    current: list[str] = []
    for ch in inner:
        if ch == ',' and depth == 0:
            args.append(''.join(current).strip())
            current = []
        else:
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
            current.append(ch)
    if current:
        args.append(''.join(current).strip())
    return [a for a in args if a]


def resolve_value(val, defines: dict):
    """Resolve a JSON value: define lookup, then arithmetic/timing expression, then raw.
    Strings matching list(...) are parsed into Python lists with each element resolved."""
    if not isinstance(val, str):
        return val
    if val.startswith('$'):
        return val  # binding reference placeholder — preserve as-is
    stripped = val.strip()
    if stripped.startswith('list(') and stripped.endswith(')'):
        inner = stripped[5:-1]
        return [resolve_value(a, defines) for a in _split_list_args(inner)]
    if val in defines:
        return defines[val]
    resolved = _resolve_expr(val, defines)
    return resolved if resolved is not None else val


def compile_node(src: dict, defines: dict) -> dict:
    """Recursively compile one source JSON node into a DM descriptor dict."""
    # Read structural keys from defines
    desc_type     = defines.get('BT_DESC_TYPE',          '__t')
    desc_children = defines.get('BT_DESC_CHILDREN',      '__c')
    desc_args     = defines.get('BT_DESC_BEHAVIOR_ARGS', 'default_behavior_args')

    node_type = src.get('type', '')
    out: dict = {}

   #Resolve what typepath we need to use for the node
    if node_type in STATIC_NODES:
        out[desc_type] = STATIC_NODES[node_type]
    elif node_type == 'decorator':
        out[desc_type] = src['decorator']
    elif node_type == 'leaf':
        out[desc_type] = src['behavior']
    elif node_type == 'subtree':
        out[desc_type] = src.get('subtype', '/datum/bt_node/subtree')
    else:
        raise ValueError(f'Unknown node type: {node_type!r}')

    # Setup children nodes recursively
    if 'children' in src:
        out[desc_children] = [compile_node(c, defines) for c in src['children']]
    elif 'child' in src:
        out[desc_children] = [compile_node(src['child'], defines)]

    # Add config
    for key, val in src.get('config', {}).items():
        out[key] = resolve_value(val, defines)

    # Behavior perform() args — "" means null (DM uses the parameter default)
    if 'args' in src:
        out[desc_args] = [None if (rv := resolve_value(a, defines)) == '' else rv for a in src['args']]

    # Instance vars — "" means omit the key (DM uses the type var default)
    for key, val in src.get('vars', {}).items():
        rv = resolve_value(val, defines)
        if rv != '':
            out[key] = rv

    # Bindings: declaration on a subtree definition file's root vs. call-site overrides
    if 'bindings' in src:
        if node_type == 'subtree':
            # Call-site overrides: resolve values through defines, emit as "bindings" (becomes node.vars)
            # Empty string means "use the default from the declaration" — omit the key.
            out['bindings'] = {k: rv for k, v in src['bindings'].items() if (rv := resolve_value(v, defines)) != ''}
        else:
            # Declaration: emit as "__bindings" with label + resolved default (consumed by DM runtime)
            out['__bindings'] = {
                name: {'label': info.get('label', name), 'default': resolve_value(info.get('default'), defines)}
                for name, info in src['bindings'].items()
            }

    # anything else
    for key, val in src.items():
        if key in _CONSUMED_KEYS:
            continue
        out[key] = resolve_value(val, defines)

    return out


def main() -> int:
    check_mode = '--check' in sys.argv

    # Determine repo root (two levels up from this script, IDK if theres a better way to do this)
    repo_root = Path(__file__).resolve().parent.parent
    for arg in sys.argv[1:]:
        if arg.startswith('--repo-root='):
            repo_root = Path(arg.split('=', 1)[1]).resolve()
        elif arg == '--repo-root' and sys.argv.index(arg) + 1 < len(sys.argv):
            idx = sys.argv.index(arg)
            repo_root = Path(sys.argv[idx + 1]).resolve()

    generated_dir = repo_root / 'build' / 'behavior_trees'
    generated_dir.mkdir(parents=True, exist_ok=True)

    print('Parsing DM defines...')
    defines = parse_defines(repo_root)
    print(f'  Resolved {len(defines)} defines.')

    bt_files = sorted(repo_root.glob('code/**/*.bt.json'))
    print(f'Found {len(bt_files)} .bt.json source files.')

    errors = 0
    dirty = 0

    for src_path in bt_files:
        # src_path.stem strips one extension, giving e.g. "simple_hostile_combat.bt"
        # We want the base name without the .bt part. so we can slam a compiled inbetween :3
        stem = src_path.stem  # "simple_hostile_combat.bt"
        name = stem[:-3] if stem.endswith('.bt') else stem  # "simple_hostile_combat"
        compiled_name = f'{name}.bt.compiled.json'
        compiled_path = generated_dir / compiled_name

        # compile json
        try:
            src_json = json.loads(src_path.read_text(encoding='utf-8'))
        except Exception as exc:
            print(f'ERROR reading {src_path.relative_to(repo_root)}: {exc}', file=sys.stderr)
            errors += 1
            continue

        try:
            compiled = compile_node(src_json, defines)
        except Exception as exc:
            print(f'ERROR compiling {src_path.relative_to(repo_root)}: {exc}', file=sys.stderr)
            errors += 1
            continue

        compiled_text = json.dumps(compiled, separators=(',', ':'))

        # either write or check depending on flag
        if check_mode:
            existing = compiled_path.read_text(encoding='utf-8') if compiled_path.exists() else ''
            if existing != compiled_text:
                print(f'OUT OF DATE: {compiled_path.relative_to(repo_root)}', file=sys.stderr)
                dirty += 1
        else:
            compiled_path.write_text(compiled_text, encoding='utf-8')

    if check_mode:
        if dirty:
            print(
                f'\n{dirty} file(s) are out of date. Run `python tools/build_bt.py` to regenerate.',
                file=sys.stderr,
            )
            return 1
        print('All generated BT files are up to date.')
        return 0

    if errors:
        print(f'\n{errors} error(s) encountered.', file=sys.stderr)
        return 1

    print('Done.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
