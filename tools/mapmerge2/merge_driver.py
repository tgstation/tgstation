#!/usr/bin/env python3
import sys
import collections
import dmm
import mapmerge

debug_stats = collections.defaultdict(int)

def select(base, left, right, *, debug=None):
    if left == right:
        # whether or not it's in the base, both sides agree
        if debug:
            debug_stats[f"select {debug} both"] += 1
        return left
    elif base == left:
        # base == left, but right is different: accept right
        if debug:
            debug_stats[f"select {debug} right"] += 1
        return right
    elif base == right:
        # base == right, but left is different: accept left
        if debug:
            debug_stats[f"select {debug} left"] += 1
        return left
    else:
        # all three versions are different
        if debug:
            debug_stats[f"select {debug} fail"] += 1
        return None

def three_way_merge(base, left, right):
    if base.size != left.size or base.size != right.size:
        print("Dimensions have changed:")
        print(f"    Base: {base.size}")
        print(f"    Ours: {left.size}")
        print(f"    Theirs: {right.size}")
        return True, None

    trouble = False
    merged = dmm.DMM(base.key_length, base.size)
    merged.dictionary = base.dictionary.copy()

    for (z, y, x) in base.coords_zyx:
        coord = x, y, z
        base_tile = base.get_tile(coord)
        left_tile = left.get_tile(coord)
        right_tile = right.get_tile(coord)

        # try to merge the whole tiles
        whole_tile_merge = select(base_tile, left_tile, right_tile, debug='tile')
        if whole_tile_merge is not None:
            merged.set_tile(coord, whole_tile_merge)
            continue

        # try to merge each group independently (movables, turfs, areas)
        base_movables, base_turfs, base_areas = dmm.split_atom_groups(base_tile)
        left_movables, left_turfs, left_areas = dmm.split_atom_groups(left_tile)
        right_movables, right_turfs, right_areas = dmm.split_atom_groups(right_tile)

        merged_movables = select(base_movables, left_movables, right_movables, debug='movable')
        merged_turfs = select(base_turfs, left_turfs, right_turfs, debug='turf')
        merged_areas = select(base_areas, left_areas, right_areas, debug='area')

        if merged_movables is not None and merged_turfs is not None and merged_areas is not None:
            merged.set_tile(coord, merged_movables + merged_turfs + merged_areas)
            continue

        # TODO: more advanced strategies?

        # fall back to requiring manual conflict resolution
        trouble = True
        print(f" C: Both sides touch the tile at {coord}")

        if merged_movables is None:
            merged_movables = left_movables + ['/obj'] + right_movables
            print(f"    Left and right movable groups are split by a generic `/obj`")
        if merged_turfs is None:
            merged_turfs = left_turfs
            print(f"    Saving turf: {', '.join(left_turfs)}")
            print(f"    Alternative: {', '.join(right_turfs)}")
            print(f"    Original:    {', '.join(base_turfs)}")
        if merged_areas is None:
            merged_areas = left_areas
            print(f"    Saving area: {', '.join(left_areas)}")
            print(f"    Alternative: {', '.join(right_areas)}")
            print(f"    Original:    {', '.join(base_areas)}")

        merged.set_tile(coord, merged_movables + merged_turfs + merged_areas)

    merged = mapmerge.merge_map(merged, base)
    return trouble, merged

def main(path, original, left, right):
    print(f"Merging map: {path}")

    map_orig = dmm.DMM.from_file(original)
    map_left = dmm.DMM.from_file(left)
    map_right = dmm.DMM.from_file(right)

    trouble, merged = three_way_merge(map_orig, map_left, map_right)
    if merged:
        merged.to_file(left)
    if trouble:
        print("!!! Manual merge required!")
        if merged:
            print("    A best-effort merge was performed. You must edit the map and confirm")
            print("    that all coordinates mentioned above are as desired.")
        else:
            print("    The map was totally unable to be merged; you must start with one version")
            print("    or the other and manually resolve the conflict. Information about the")
            print("    conflicting tiles is listed above.")
    print(f"    Debug stats: {dict(debug_stats)}")
    return trouble

if __name__ == '__main__':
    if len(sys.argv) != 6:
        print("DMM merge driver called with wrong number of arguments")
        print("    usage: merge-driver-dmm %P %O %A %B %L")
        exit(1)

    # "left" is also the file that ought to be overwritten
    _, path, original, left, right, conflict_size_marker = sys.argv
    exit(main(path, original, left, right))
