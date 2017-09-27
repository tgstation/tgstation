#!/usr/bin/env python3
import frontend
import shutil
from dmm import *

def merge_map(new_map, old_map):
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
    old_dict = sort_dictionary(old_map.dictionary) # impose order; old_dict is used in the end as the merged dictionary
    old_grid = old_map.grid

    merged_grid = dict()
    known_keys = dict()
    unused_keys = list(old_map.dictionary.keys())

    # both old and new dictionary in lists, for faster key lookup by tile tuple
    old_dict_keys = list(old_dict.keys())
    old_dict_values = list(old_dict.values())
    new_dict_keys = list(new_dict.keys())
    new_dict_values = list(new_dict.values())

    # step one: parse the new version, compare it to the old version, merge both
    for z in range(1, size.z + 1):
        for y in range(1, size.y + 1):
            for x in range(1, size.x + 1):
                new_key = new_grid[x, y, z]
                # if this key has been processed before, it can immediately be merged
                known_value = known_keys.get(new_key)
                if known_value:
                    merged_grid[x, y, z] = known_value
                    continue

                old_key = old_grid[x, y, z]
                old_tile = old_dict[old_key]
                new_tile = new_dict[new_key]

                # this tile is the exact same as before, so the old key is used
                if new_tile == old_tile:
                    merged_grid[x, y, z] = old_key
                    known_keys[new_key] = old_key
                    try:
                        unused_keys.remove(old_key)
                    except ValueError:
                        print(f"Notice: Correcting duplicate dictionary entry. ({new_key})")
                    continue

                # the tile is different here, but if it exists in the old dictionary, its old key can be used
                newold_key = get_key(old_dict_keys, old_dict_values, new_tile)
                if newold_key is not None:
                    merged_grid[x, y, z] = newold_key
                    known_keys[new_key] = newold_key
                    try:
                        unused_keys.remove(old_key)
                    except ValueError:
                        print(f"Notice: Correcting duplicate dictionary entry. ({new_key})")
                    continue

                # the tile is brand new and it needs a new key, but if the old key isn't being used any longer it can be used instead
                elif get_key(new_dict_keys, new_dict_values, old_tile) is None:
                    merged_grid[x, y, z] = old_key
                    old_dict[old_key] = new_tile
                    known_keys[new_key] = old_key
                    unused_keys.remove(old_key)

                # all other options ruled out, a brand new key is generated for the brand new tile
                else:
                    fresh_key = generate_new_key(old_dict)
                    old_dict[fresh_key] = new_tile
                    merged_grid[x, y, z] = fresh_key

    # step two: clean the dictionary if it has too many unused keys
    output_map = DMM(key_length, size)
    output_map.dictionary = old_dict
    output_map.grid = merged_grid

    if len(unused_keys) > min(1600, len(old_dict) * 0.5):
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
