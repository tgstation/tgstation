#!/usr/bin/env python3
import collections
import frontend
import dmm

def autofix_map(the_map):
    fixed = collections.defaultdict(int)

    # Apply fixes
    for k, v in the_map.dictionary.items():
        # Stacking catwalks on top of lattices (prefer catwalks)
        if '/obj/structure/lattice/catwalk' in v and '/obj/structure/lattice' in v:
            v = tuple(i for i in v if i != '/obj/structure/lattice')
            fixed['catwalk stacking'] += 1

        the_map.dictionary[k] = v

    # Describe fixes
    for k, v in fixed.items():
        print("{}: fixed {} instances".format(k, v))
    if not fixed:
        print("Nothing to fix.")

    return the_map

def main(settings):
    for fname in frontend.process(settings, "autofix", backup=True):
        autofix_map(dmm.DMM.from_file(fname)).to_file(fname, settings.tgm)

if __name__ == '__main__':
    main(frontend.read_settings())
