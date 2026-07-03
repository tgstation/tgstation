import sys
from pathlib import Path

if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("usage: merge_ru_names.py <header> <fragments-dir> <output>")

    header, fragments, output = map(Path, sys.argv[1:4])
    if not header.is_file():
        sys.exit(f"merge_ru_names.py: header not found: {header}")

    output.parent.mkdir(parents=True, exist_ok=True)
    tmp = output.with_suffix(output.suffix + ".tmp")
    parts = [header.read_text(encoding="utf-8")]
    parts.extend(f.read_text(encoding="utf-8") + "\n" for f in sorted(fragments.rglob("*.toml")))
    tmp.write_text("".join(parts), encoding="utf-8")
    tmp.replace(output)
