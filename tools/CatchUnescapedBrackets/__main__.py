import sys
from pathlib import Path
import argparse

RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"

def find_lone_arrays(src: str):
    results = []

    in_string = False
    escaped = False

    in_text_call = False
    paren_depth = 0

    in_line_comment = False
    in_block_comment = False

    line = 1
    col = 0

    i = 0
    length = len(src)

    while i < length:
        ch = src[i]
        nxt = src[i + 1] if i + 1 < length else ""

        col += 1

        if ch == '\n':
            line += 1
            col = 0
            in_line_comment = False

        # comments
        if not in_string and not in_block_comment and not in_line_comment:
            if ch == '/' and nxt == '/':
                in_line_comment = True
                i += 2
                col += 1
                continue
            if ch == '/' and nxt == '*':
                in_block_comment = True
                i += 2
                col += 1
                continue

        if in_block_comment:
            if ch == '*' and nxt == '/':
                in_block_comment = False
                i += 2
                col += 1
                continue
            i += 1
            continue

        if in_line_comment:
            i += 1
            continue

        # --- Escapes ---
        if escaped:
            escaped = False
            i += 1
            continue

        if ch == '\\':
            escaped = True
            i += 1
            continue

        # --- Detect text( ---
        if not in_string and not in_text_call:
            if src.startswith("text(", i):
                in_text_call = True
                paren_depth = 1
                i += 5
                col += 4
                continue

        # skip everything inside text()
        if in_text_call:
            if ch == '(':
                paren_depth += 1
            elif ch == ')':
                paren_depth -= 1
                if paren_depth == 0:
                    in_text_call = False
            i += 1
            continue

        # string handling
        if ch == '"':
            in_string = not in_string
            i += 1
            continue

        # illegal []
        if in_string and ch == '[' and nxt == ']':
            results.append((line, col))
            i += 2
            col += 1
            continue

        i += 1

    return results


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("path", nargs="?", default=".", help="Path to scan")
    parser.add_argument("-i", "--ignore", action="append", default=[], help="Paths to ignore")
    args = parser.parse_args()

    path = Path(args.path)
    ignore_paths = [Path(i).resolve() for i in args.ignore]

    if not path.exists():
        print(f"Path does not exist: {path}")
        sys.exit(2)

    violations = 0

    if path.is_file() and path.suffix == ".dm":
        files_to_scan = [path]
    elif path.is_dir():
        files_to_scan = []
        for p in path.rglob("*.dm"):
            if any(p.resolve() == target or target in p.resolve().parents for target in ignore_paths):
                continue
            files_to_scan.append(p)
    else:
        print(f"Invalid path: {path}. Must be a .dm file or a directory.")
        sys.exit(2)

    for dm_file in files_to_scan:
        try:
            src = dm_file.read_text(encoding="utf-8", errors="replace")
        except Exception as e:
            print(f"[ERROR] {dm_file}: {e}")
            continue

        for line, col in find_lone_arrays(src):
            print(
                f"{RED}ERROR{NC}: {dm_file}:{line}:{col} "
                f"illegal [] inside string"
            )
            violations += 1

    if violations:
        print()
        print(
            f"{RED}ERROR:{NC} Found {violations} illegal unescaped [] occurrence(s). "
            "Please remove or escape them."
        )
        sys.exit(1)

    print(f"{GREEN}OK:{NC} No illegal [] found.")
    sys.exit(0)

if __name__ == "__main__":
    main()
