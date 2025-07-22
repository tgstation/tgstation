'''
Usage:
    $ python photo_json_to_ckeys.py path/to/photo_albums.json -o path/to/photo_albums.json

This script is designed to convert all personal entries in photo_albums.json to ckey() format.
It will also merge any entries that are from the same ckey into a single record.
The intent here is to provide hosts with a quick and easy way to fix their persistence json files.

'''

#!/usr/bin/env python3
import argparse, json
import re
from collections import defaultdict

def detect_eol(text: str) -> str:
    if '\r\n' in text:
        return '\r\n'
    elif '\r' in text:
        return '\r'
    else:
        return '\n'

def ckey(text: str) -> str:
    t = text.lower()
    return ''.join(ch for ch in t if ch.isalnum() or ch == '@')

def merge_ckey_entries(data: dict) -> dict:
    merged = defaultdict(lambda: {"ids": [], "has_null": False})
    for orig, reps in data.items():
        norm = ("personal_" + ckey(orig[len("personal_"):])) if orig.startswith("personal_") else orig
        entry = merged[norm]
        if reps is None:
            entry["has_null"] = True
        else:
            for rep in reps:
                if rep is None:
                    entry["has_null"] = True
                else:
                    entry["ids"].append(rep)

    output = {}
    for k, info in merged.items():
        seen, unique = set(), []
        for i in info["ids"]:
            if i not in seen:
                seen.add(i)
                unique.append(i)
        if unique:
            output[k] = unique
        elif info["has_null"]:
            output[k] = None
        else:
            output[k] = []
    return output

def main():
    p = argparse.ArgumentParser()
    p.add_argument('infile', help='Input JSON file path')
    p.add_argument('-o', '--output', help='Output JSON file path (optional)')
    args = p.parse_args()

    txt = open(args.infile, 'r', encoding='utf-8', newline='').read()
    eol = detect_eol(txt)
    data = json.loads(txt)
    merged = merge_ckey_entries(data)

    out_text = json.dumps(merged, indent='\t', separators=(', ', ': '))

    if args.output:
        with open(args.output, 'w', encoding='utf-8', newline='') as out:
            out.write(out_text)
    else:
        print(out_text, end='')

if __name__ == '__main__':
    main()

