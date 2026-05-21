import re
import sys
import subprocess
from pathlib import Path

# ==========================================================
# REGEX
# ==========================================================
KEY_BLOCK_RE = re.compile(
    r'"([^"]+)"\s*=\s*\((.*?)\)',
    re.DOTALL
)


# ==========================================================
# GIT ROOT
# ==========================================================
def get_git_root(start_dir: Path) -> Path:
    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=start_dir,
            stderr=subprocess.DEVNULL,
        )
        return Path(out.decode().strip())
    except Exception as e:
        raise SystemExit(f"Failed to determine git repo root: {e}")


# ==========================================================
# LOGIC
# ==========================================================
def block_needs_replacement(block: str) -> bool:
    """
    A block needs replacement if:
      - it contains /area/template_noop
      - AND it has either an /obj OR a /turf that is not /turf/template_noop
    """
    if "/area/template_noop" not in block:
        return False

    has_obj = re.search(r'^\s*/obj/', block, re.MULTILINE) is not None

    has_non_template_turf = False
    for m in re.finditer(r'^\s*(/turf[^\s,{]*)', block, re.MULTILINE):
        turf_path = m.group(1)
        if turf_path != "/turf/template_noop":
            has_non_template_turf = True
            break

    return has_obj or has_non_template_turf


def process_dmm(path: Path, git_root: Path) -> None:
    text = path.read_text(encoding="utf8")

    changed = False
    changed_keys = []

    def repl(match: re.Match) -> str:
        nonlocal changed

        key_name = match.group(1)
        block = match.group(2)

        if not block_needs_replacement(block):
            return match.group(0)

        new_block = block.replace("/area/template_noop", "/area/space/nearstation")

        if new_block == block:
            return match.group(0)

        changed = True
        changed_keys.append(key_name)

        return match.group(0).replace(block, new_block)

    new_text = KEY_BLOCK_RE.sub(repl, text)

    if changed:
        path.write_text(new_text, encoding="utf8")
        try:
            rel = path.relative_to(git_root)
        except ValueError:
            rel = path
        print(f"[{rel}] updated keys: {', '.join(changed_keys)}")


# ==========================================================
# MAIN
# ==========================================================
def main():
    if len(sys.argv) < 2:
        print("Usage: python fix_template_noop_areas.py <path-to-search>")
        print("  <path-to-search> can be:")
        print("    - relative to the git root (tgstation)")
        print("    - or an absolute path")
        sys.exit(1)

    script_dir = Path(__file__).resolve().parent
    git_root = get_git_root(script_dir)
    print(f"[INFO] Git root: {git_root}")

    arg_path = Path(sys.argv[1])

    if arg_path.is_absolute():
        root_dir = arg_path
    else:
        root_dir = git_root / arg_path

    print(f"[INFO] Searching under: {root_dir}")

    if not root_dir.is_dir():
        raise SystemExit(f"[ERROR] Search path does not exist or is not a directory: {root_dir}")

    dmm_files = sorted(root_dir.rglob("*.dmm"))
    total = len(dmm_files)

    if total == 0:
        print(f"[INFO] No .dmm files found under {root_dir}")
        return

    print(f"[INFO] Found {total} .dmm files")

    for idx, dmm in enumerate(dmm_files, start=1):
        print(f"[INFO] ({idx}/{total}) Processing: {dmm}")
        process_dmm(dmm, git_root)

    print("[INFO] Done.")

if __name__ == "__main__":
    main()
