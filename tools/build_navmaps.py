#!/usr/bin/env python3
"""Generate or check station navmap files."""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "build" / "navmaps"
INDEX_NAME = "index.json"
RULES_VERSION_PATH = ROOT / "code" / "__DEFINES" / "navmap.dm"


def bake_rules_version() -> int:
    try:
        source = RULES_VERSION_PATH.read_text(encoding="utf-8")
    except OSError as error:
        raise RuntimeError(f"Couldn't read {RULES_VERSION_PATH.relative_to(ROOT)}") from error
    matches = re.findall(r"^#define NAVMAP_BAKE_RULES_VERSION ([1-9][0-9]*)$", source, re.MULTILINE)
    if len(matches) != 1:
        raise RuntimeError("Couldn't find one valid NAVMAP_BAKE_RULES_VERSION in code/__DEFINES/navmap.dm")
    return int(matches[0])


def station_configs() -> list[tuple[str, Path]]:
    configs = []
    for config_path in sorted((ROOT / "_maps" / "map_jsons").glob("*.json")):
        try:
            config = json.loads(config_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise RuntimeError(f"Couldn't read map {config_path.relative_to(ROOT)}: {error}") from error
        if "map_path" not in config or "map_file" not in config:
            print(f"Skipping {config_path.name}: no station map", file=sys.stderr)
            continue
        configs.append((config_path.stem, config_path))
    return configs


def changed_station_configs(configs: list[tuple[str, Path]], base: str) -> list[tuple[str, Path]]:
    changed = set(subprocess.check_output(
        ["git", "diff", "--name-only", "--no-renames", "-z", base, "HEAD", "--"], cwd=ROOT,
    ).decode("utf-8").split("\0"))
    shared_files = {"dependencies.sh", "tools/build_navmaps.py", ".github/workflows/check_navmap_bakes.yml"}
    shared_directories = (
        "tools/build/", "tools/bootstrap/", "_maps/map_files/generic/",
        ".github/actions/configure_byond_version/", ".github/actions/restore_or_install_byond/",
        ".github/actions/setup_bun/",
    )
    if any(path.endswith((".dm", ".dme")) or path in shared_files or path.startswith(shared_directories) for path in changed):
        return configs
    selected = []
    for name, config_path in configs:
        config = json.loads(config_path.read_text(encoding="utf-8"))
        files = config["map_file"]
        if isinstance(files, str):
            files = [files]
        inputs = {
            config_path.relative_to(ROOT).as_posix(),
            f"build/navmaps/{name}.navmap.json",
        }
        for filename in files:
            inputs.add((ROOT / "_maps" / config["map_path"] / filename).resolve().relative_to(ROOT).as_posix())
        if changed & inputs:
            selected.append((name, config_path))
    return selected


def build_generator_dmb() -> None:
    suffix = ".bat" if os.name == "nt" else ".sh"
    build_script = ROOT / "tools" / "build" / f"build{suffix}"
    command = [str(build_script), "navmap-bake-compile"]
    if os.name == "nt":
        command = ["cmd.exe", "/c", *command]
    try:
        subprocess.run(command, cwd=ROOT, check=True)
    except subprocess.CalledProcessError as error:
        raise RuntimeError("Couldn't compile the navmap builder. Check the output above.") from error


def canonical_json(value: object) -> bytes:
    return (json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n").encode("utf-8")


def validate_generated_cache(cache: object, expected_rules_version: int, config_path: Path) -> dict:
    """Check the generated file's layout."""
    try:
        if cache["format_version"] != 1 or cache["bake_rules_version"] != expected_rules_version:
            raise ValueError("wrong bake version")
        if cache["map_config"] != config_path.relative_to(ROOT).as_posix():
            raise ValueError("wrong map config")
        if not re.fullmatch(r"[0-9a-f]{32}", cache["map_fingerprint"]):
            raise ValueError("bad map ID")
        if not isinstance(cache["layers"], list) or not cache["layers"]:
            raise ValueError("no station layers found")
        for layer in cache["layers"]:
            width, height = layer["width"], layer["height"]
            if any(type(size) is not int or size <= 0 for size in (width, height)):
                raise ValueError("bad layer size")
            palette, runs = layer["palette"], layer["runs"]
            if not isinstance(palette, list) or not palette or not isinstance(runs, list):
                raise ValueError("missing tile data")
            for entry in palette:
                if entry is not None and (
                    not isinstance(entry, list)
                    or len(entry) != 2
                    or any(type(value) is not int or value < 0 for value in entry)
                ):
                    raise ValueError("bad tile value")
            expanded = 0
            for count, index in runs:
                if type(count) is not int or count <= 0 or type(index) is not int or not 0 <= index < len(palette):
                    raise ValueError("bad tile run")
                expanded += count
            if expanded != width * height:
                raise ValueError("tile runs do not fill the layer")
    except (KeyError, TypeError, ValueError) as error:
        raise RuntimeError(f"Bad navmap for {config_path.name}: {error}") from error
    return cache


def generate_cache(config_name: str, config_path: Path, expected_rules_version: int) -> dict:
    raw_path = OUTPUT_DIR / f"{config_name}.raw.json"
    suffix = ".bat" if os.name == "nt" else ".sh"
    build_script = ROOT / "tools" / "build" / f"build{suffix}"
    command = [
        str(build_script),
        "navmap-bake-run",
        f"--map-config={config_path.relative_to(ROOT).as_posix()}",
    ]
    if os.name == "nt":
        command = ["cmd.exe", "/c", *command]
    try:
        subprocess.run(command, cwd=ROOT, check=True, timeout=900)
    except subprocess.CalledProcessError as error:
        raise RuntimeError(f"Couldn't bake {config_name}. Check the output above.") from error
    except subprocess.TimeoutExpired as error:
        raise RuntimeError(f"Baking {config_name} took too long. Check the output above.") from error
    if not raw_path.is_file():
        raise RuntimeError(f"{config_name} finished without writing a navmap. Check the output above.")
    try:
        cache = json.loads(raw_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError(f"Couldn't read the new navmap for {config_name}: {error}") from error
    cache = validate_generated_cache(cache, expected_rules_version, config_path)
    raw_path.unlink()
    return cache


def perform(args: argparse.Namespace) -> int:
    expected_rules_version = bake_rules_version()
    all_configs = station_configs()
    configs = all_configs
    if args.map:
        configs = [item for item in configs if item[0] == args.map]
        if not configs:
            raise RuntimeError(f"No station map named {args.map!r}")
    if args.changed_since:
        configs = changed_station_configs(configs, args.changed_since)
    if args.list_maps:
        print(json.dumps([name for name, _ in configs], separators=(",", ":")))
        return 0
    if not all_configs:
        raise RuntimeError("No station maps found")

    (ROOT / "tmp").mkdir(parents=True, exist_ok=True)

    if not args.check:
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    if configs:
        build_generator_dmb()
    else:
        print("No station navmaps need baking; checking the saved file list and index")
    staged: dict[Path, bytes] = {}
    index_path = OUTPUT_DIR / INDEX_NAME
    if args.map and index_path.exists():
        try:
            index = json.loads(index_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as error:
            raise RuntimeError(f"Couldn't read {INDEX_NAME}: {error}") from error
    else:
        index = {}
    with tempfile.TemporaryDirectory(prefix="navmap-bakes-", dir=ROOT / "tmp") as temporary:
        temp_dir = Path(temporary)
        for name, config_path in configs:
            cache = generate_cache(name, config_path, expected_rules_version)
            fingerprint = cache["map_fingerprint"]
            filename = f"{name}.navmap.json"
            index = {key: path for key, path in index.items() if path != f"build/navmaps/{filename}"}
            if fingerprint in index and index[fingerprint] != f"build/navmaps/{filename}":
                raise RuntimeError(f"{name} and {index[fingerprint]} have the same map ID")
            index[fingerprint] = f"build/navmaps/{filename}"
            staged[OUTPUT_DIR / filename] = canonical_json(cache)
            print(f"Generated {name}: {len(cache['layers'])} station layer(s)")
        if args.changed_since:
            index = {}
            for name, config_path in all_configs:
                output_path = OUTPUT_DIR / f"{name}.navmap.json"
                contents = staged.get(output_path)
                if contents is None:
                    try:
                        contents = output_path.read_bytes()
                    except FileNotFoundError:
                        continue
                try:
                    cache = json.loads(contents)
                except json.JSONDecodeError as error:
                    raise RuntimeError(f"Couldn't read {output_path.name}: {error}") from error
                cache = validate_generated_cache(cache, expected_rules_version, config_path)
                fingerprint = cache["map_fingerprint"]
                if fingerprint in index:
                    raise RuntimeError(f"{name} has a duplicate map ID")
                index[fingerprint] = output_path.relative_to(ROOT).as_posix()
        staged[OUTPUT_DIR / INDEX_NAME] = canonical_json(index)

        if args.check:
            mismatches = []
            if not args.map:
                expected_names = {f"{name}.navmap.json" for name, _ in all_configs}
                present_names = {path.name for path in OUTPUT_DIR.glob("*.navmap.json")}
                mismatches.extend(sorted(expected_names - present_names))
                mismatches.extend(sorted(present_names - expected_names))
            checked_outputs = staged.items() if not args.map else [
                (path, contents) for path, contents in staged.items() if path.name != INDEX_NAME
            ]
            for output_path, expected in checked_outputs:
                try:
                    actual = output_path.read_bytes()
                except OSError:
                    mismatches.append(output_path.relative_to(ROOT).as_posix())
                    continue
                if actual != expected:
                    mismatches.append(output_path.relative_to(ROOT).as_posix())
            if mismatches:
                mismatch_dir = ROOT / "tmp" / "navmap-bake-check"
                shutil.rmtree(mismatch_dir, ignore_errors=True)
                mismatch_dir.mkdir(parents=True, exist_ok=True)
                for output_path, expected in staged.items():
                    (mismatch_dir / output_path.name).write_bytes(expected)
                raise RuntimeError("These navmaps need rebuilding: " + ", ".join(mismatches))
            print("Generated navmaps are up to date")
            return 0

        temp_dir.mkdir(parents=True, exist_ok=True)
        for output_path, contents in staged.items():
            output_path.parent.mkdir(parents=True, exist_ok=True)
            temporary_output = temp_dir / output_path.name
            temporary_output.write_bytes(contents)
            os.replace(temporary_output, output_path)
            print(f"Saved {output_path.relative_to(ROOT).as_posix()}")
        if not args.map:
            expected_names = {path.name for path in staged if path.name.endswith(".navmap.json")}
            for stale_path in OUTPUT_DIR.glob("*.navmap.json"):
                if stale_path.name not in expected_names:
                    stale_path.unlink()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    selection = parser.add_mutually_exclusive_group()
    selection.add_argument("--map", help="generate only one map config, e.g. deltastation")
    selection.add_argument("--changed-since", help="check only station maps affected by changes since a Git revision")
    parser.add_argument("--list-maps", action="store_true", help="list selected map names as JSON without baking")
    parser.add_argument("--check", action="store_true", help="verify tracked outputs without writing them")
    args = parser.parse_args()
    if args.changed_since and not (args.check or args.list_maps):
        parser.error("--changed-since requires --check or --list-maps")
    try:
        return perform(args)
    except (OSError, RuntimeError, subprocess.CalledProcessError, subprocess.TimeoutExpired) as error:
        print(f"Navmap build failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
