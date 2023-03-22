#!/usr/bin/env python3
import os
import pathlib
import re
from mapmerge2 import dmm

top_left = 1
top_right = 4
bottom_right = 2
bottom_left = 8

# Mapping of path{dir}s to corner dirs, so we can optimize them into the largest piece. Sorted by priority (size of set covered)
path_dir_sets = {
    ("/fourcorners/contrasted", 2): frozenset({top_left, top_right, bottom_left, bottom_right}),
    ("/fourcorners", 2): frozenset({top_left, top_right, bottom_left, bottom_right}),
    ("/anticorner", 1): frozenset({top_left, top_right, bottom_left}),
    ("/anticorner", 2): frozenset({top_right, bottom_left, bottom_right}),
    ("/anticorner", 4): frozenset({top_left, top_right, bottom_right}),
    ("/anticorner", 8): frozenset({top_left, bottom_left, bottom_right}),
    ("/anticorner/contrasted", 1): frozenset({top_left, top_right, bottom_left}),
    ("/anticorner/contrasted", 2): frozenset({top_right, bottom_left, bottom_right}),
    ("/anticorner/contrasted", 4): frozenset({top_left, top_right, bottom_right}),
    ("/anticorner/contrasted", 8): frozenset({top_left, bottom_left, bottom_right}),
    ("/half", 1): frozenset({top_left, bottom_left}),
    ("/half", 2): frozenset({top_right, bottom_right}),
    ("/half", 4): frozenset({top_left, top_right}),
    ("/half", 8): frozenset({bottom_left, bottom_right}),
    ("/half/contrasted", 1): frozenset({top_left, bottom_left}),
    ("/half/contrasted", 2): frozenset({top_right, bottom_right}),
    ("/half/contrasted", 4): frozenset({top_left, top_right}),
    ("/half/contrasted", 8): frozenset({bottom_left, bottom_right}),
    ("/opposingcorners", 1): frozenset({bottom_left, top_right}),
    ("/opposingcorners", 2): frozenset({top_left, bottom_right}),
    ("", 1): frozenset({top_left}),
    ("", 2): frozenset({bottom_right}),
    ("", 4): frozenset({top_right}),
    ("", 8): frozenset({bottom_left}),
}

path_dir_sets_reverse = {}
for k, v in path_dir_sets.items():
    path_dir_sets_reverse[v] = path_dir_sets_reverse.get(v, []) + [k]

# We don't want to turn "contrasted" into fulltile decals
compatibility_sets = [
    {"", "/half/contrasted", "/opposingcorners", "/fourcorners/contrasted", "/anticorner/contrasted"},
    {"/half", "/anticorner", "/fourcorners"}
]

def update_map(map_path):
    the_map = dmm.DMM.from_file(map_path)
    checked = 0
    for z, y, x in the_map.coords_zyx:
        coord = x, y, z
        tile, turfs, areas = dmm.split_atom_groups(the_map.get_tile(coord))
        turf_decals = list(filter(lambda atom: atom.startswith('/obj/effect/turf_decal/tile'), tile))
        if not turf_decals or len(turf_decals) <= 0:
            continue
        checked += 1
        typed = dict()
        for decal in turf_decals:
            matched = re.search(r"\/obj\/effect\/turf_decal\/tile\/?([A-Za-z_]+)?([A-Za-z_\/]+)?(\{[\s\S]*(dir = (\d+))[\s\S]*\})?", decal)
            if matched == None:
                print("Warning, what the fuck did we just parse? {}".format(decal))
            color = matched.group(1)
            if color == None: # Corg, you big dummy, you can't just use a null preset for white
                print("Warning, tile with no color (this is bad): {}".format(decal))
                color = "white"
            last = matched.group(2)
            if last == None:
                last = ""
            dir = matched.group(5)
            if dir == None:
                dir = 2
            else:
                dir = int(dir)
            dirs = None
            if last == "":
                dirs = frozenset({ dir })
            else:
                # add in tile_side_map so we can parse it out, but don't use the reverse later
                dirs = frozenset((path_dir_sets)[(last, dir)])
            if dirs == None:
                print("Warning - Could not parse tile decal to corners: {}".format(decal))
            else:
                tile.remove(decal)
                typed[(color, last)] = typed[(color, last)] | dirs if (color, last) in typed else dirs
        for data, dirs in typed.items():
            color = data[0]
            last = data[1]
            result = None
            results = path_dir_sets_reverse[dirs]
            if len(results) > 1:
                for rez in results:
                    for comp in compatibility_sets:
                        if last in comp and rez[0] in comp:
                            result = rez
                            break
                    if result != None:
                        break
                if result == None:
                    print(results)
                    print(last)
            elif len(results) == 1:
                result = results[0]
            if result == None:
                print("Warning - no applicable type for dirs: {}".format(dirs))
                print(turf_decals)
            # Handle the case where color is empty, we need the path to not end in /
            if color != "":
                color = "/" + color
            new_path = "/obj/effect/turf_decal/tile" + color + result[0]
            new_dir = result[1]
            if new_dir != 2:
                new_path += "{dir = " + str(new_dir) + "}"
            tile.append(new_path)
        the_map.set_tile(coord, tile + turfs + areas)
    return (the_map, checked)

if __name__ == '__main__':
    print("hi")
    list_of_files = list()
    for root, directories, filenames in os.walk("../../_maps/"):
        for filename in [f for f in filenames if f.endswith(".dmm")]:
            list_of_files.append(pathlib.Path(root, filename))
    for path in list_of_files:
        data = update_map(path)
        if data[1] > 0:
            data[0].to_file(path)
