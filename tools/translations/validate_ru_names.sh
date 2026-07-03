#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

HEADER=tools/translations/ru_names_header.toml
FRAGMENTS=modular_bandastation/translations/public/ru_names
OUTPUT=modular_bandastation/translations/public/ru_names.toml

tools/bootstrap/python tools/translations/merge_ru_names.py "$HEADER" "$FRAGMENTS" "$OUTPUT"
exec tools/bootstrap/python tools/translations/validate_ru_names.py "$OUTPUT"
