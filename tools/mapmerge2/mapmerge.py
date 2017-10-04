#!/usr/bin/env python3
import frontend
import shutil
from dmm import *

def merge_map(new_map, old_map, delete_unused=False):
    if new_map.key_length != old_map.key_length:
        print("Warning: Key lengths differ, taking new map")
        print(f"  Old: {old_map.key_length}")
        print(f"  New: {new_map.key_length}")
        return new_map

    if new_map.size != old_map.size:
        print("Warning: Map dimensions differ, taking new map")
        print(f"  Old: {old_map.size}")
        print(f"  New: {new_map.size}")
        return new_map

    key_length = old_map.key_length
    size = old_map.size
    new_dict = new_map.dictionary
    new_grid = new_map.grid
    old_dict = old_map.dictionary
    old_grid = old_map.grid

    merged_grid = dict()
    merged_dict = old_map.dictionary.copy()
    known_keys = dict()
    unused_keys = set(old_dict.keys())

    # step one: parse the new version, compare it to the old version, merge both
    for z, y, x in new_map.coords_zyx:
        new_key = new_grid[x, y, z]
        # if this key has been processed before, it can immediately be merged
        if new_key in known_keys:
            merged_grid[x, y, z] = known_keys[new_key]
            continue

        def select_key(assigned):
            merged_grid[x, y, z] = known_keys[new_key] = assigned
        def mark_used(assigned):
            try:
                unused_keys.remove(assigned)
            except ValueError:
                print(f"Notice: Correcting duplicate dictionary entry. ({new_key})")

        old_key = old_grid[x, y, z]
        old_tile = old_dict[old_key]
        new_tile = new_dict[new_key]

        # this tile is the exact same as before, so the old key is used
        if new_tile == old_tile:
            select_key(old_key)
            mark_used(old_key)

        # the tile is different here, but if it exists in the old dictionary, its old key can be used
        elif new_tile in merged_dict.inv:
            newold_key = merged_dict.inv[new_tile]
            select_key(newold_key)
            mark_used(newold_key)

        # the tile is brand new and it needs a new key, but if the old key isn't being used any longer it can be used instead
        elif old_tile not in new_dict.inv:
            merged_dict[old_key] = new_tile
            select_key(old_key)
            mark_used(old_key)

        # all other options ruled out, a brand new key is generated for the brand new tile
        else:
            fresh_key = generate_new_key(merged_dict)
            merged_dict[fresh_key] = new_tile
            select_key(fresh_key)

    # step two: clean the dictionary if it has too many unused keys
    output_map = DMM(key_length, size)
    output_map.dictionary = merged_dict
    output_map.grid = merged_grid

    if len(unused_keys) > min(1600, len(old_dict) * 0.5) or delete_unused:
        print("Notice: Trimming the dictionary.")
        output_map = trim_dictionary(output_map)
        print(f"Notice: Trimmed out {len(unused_keys)} unused dictionary keys.")
        output_map.header = f"//Model dictionary trimmed on: {datetime.utcnow().strftime('%d-%m-%Y %H:%M (UTC)')}"

    return output_map

def main(settings):
    for fname in frontend.process(settings, "merge", backup=True):
        old_map = DMM.from_file(fname + ".backup")
        new_map = DMM.from_file(fname)
        merge_map(old_map, new_map).to_file(fname, settings.tgm)

if __name__ == '__main__':
    main(frontend.read_settings())
