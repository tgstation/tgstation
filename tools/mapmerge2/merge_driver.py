#!/usr/bin/env python3
import sys
import collections
from . import dmm, mapmerge
from hooks.merge_frontend import MergeDriver


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
            # Note that if you do not have an object that matches this path in your DME, the invalid path may be discarded when the map is loaded into a map editor.
            # To rectify this, either add an object with this same path, or create a new object/denote an existing object in the obj_path define.
            obj_path = "/obj/merge_conflict_marker"
            obj_name = "---Merge Conflict Marker---"
            obj_desc = "A best-effort merge was performed. You must resolve this conflict yourself (manually) and remove this object once complete."
            merged_movables = left_movables + [f'{obj_path}{{name = "{obj_name}",\n\tdesc = "{obj_desc}"}}'] + right_movables
            print(f"    Left and right movable groups are split by an `{obj_path}` named \"{obj_name}\"")
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


class DmmDriver(MergeDriver):
    driver_id = 'dmm'

    def merge(self, base, left, right):
        map_base = dmm.DMM.from_bytes(base.read())
        map_left = dmm.DMM.from_bytes(left.read())
        map_right = dmm.DMM.from_bytes(right.read())
        trouble, merge_result = three_way_merge(map_base, map_left, map_right)
        return not trouble, merge_result

    def to_file(self, outfile, merge_result):
        outfile.write(merge_result.to_bytes())

    def post_announce(self, success, merge_result):
        if not success:
            print("!!! Manual merge required!")
            if merge_result:
                print("    A best-effort merge was performed. You must edit the map and confirm")
                print("    that all coordinates mentioned above are as desired.")
            else:
                print("    The map was totally unable to be merged; you must start with one version")
                print("    or the other and manually resolve the conflict. Information about the")
                print("    conflicting tiles is listed above.")


if __name__ == '__main__':
    exit(DmmDriver().main())
