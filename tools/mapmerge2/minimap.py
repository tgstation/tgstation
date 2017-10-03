#!/usr/bin/env python3
import dmm
import dmi
import objtree
from collections import namedtuple, ChainMap
from PIL import Image, ImageColor, ImageOps

STATION_Z = 2
TILE_SIZE = 32
DEFINES = {
    'TURF_LAYER': '2',
    'OBJ_LAYER': '3',
    'MOB_LAYER': '4',
    'FLY_LAYER': '5',
}
# Needed because objtree.xml is trash
COLOR_HACK = {
    '25500': '#ff0000',
    '02550': '#00ff00',
    '00255': '#0000ff',
}

Context = namedtuple('Context', ['map', 'objtree'])
Entry = namedtuple('Entry', ['atom', 'pos'])

def simple_layer(atom):
    layer = atom.vars['layer']
    return float(DEFINES.get(layer, layer))

def layer_of(entry=None, atom=None):
    atom = atom or entry.atom
    if atom.path.startswith('/turf/open/floor/plating') or atom.path.startswith('/turf/open/space'):
        return -10  # under everything
    elif atom.path.startswith('/turf/closed/mineral/'):
        return -3   # above hidden stuff and plating but below walls
    elif atom.path.startswith('/turf/open/floor/') or atom.path.startswith('/turf/closed/'):
        return -2   # above hidden pipes and wires
    elif atom.path.startswith('/turf'):
        return -10  # under everything
    elif atom.path.startswith('/obj/effect/turf_decal'):
        return -1   # above turfs
    elif atom.path.startswith('/obj/structure/disposalpipe'):
        return -6
    elif atom.path.startswith('/obj/machinery/atmospherics/pipe/') and 'hidden' in atom.path:
        return -5
    elif atom.path.startswith('/obj/structure/cable'):
        return -4
    elif atom.path.startswith('/area'):
        return 10
    else:
        return simple_layer(atom)

def tint(src, tint):
    tr, tg, tb = ImageColor.getrgb(tint)
    luts = (
        tuple(lr * tr // 256 for lr in range(256)) +
        tuple(lg * tg // 256 for lg in range(256)) +
        tuple(lb * tb // 256 for lb in range(256)) +
        tuple(range(256)))
    return src.point(luts)

def atom_list(ctx, coord):
    for entry in ctx.map.dictionary[ctx.map.grid[coord]]:
        path, atom_vars = dmm.parse_map_atom(entry)
        obj = ctx.objtree.find(path[1:])
        if obj is None:
            continue
        atom = objtree.Atom(obj, coord, atom_vars)

        # apply window spawners
        if path.startswith('/obj/effect/spawner/structure/'):
            # TODO: unhack this when the objtree is less bad
            for each in atom.vars['spawn_list'].split('/obj/'):
                if not each: continue
                realpath = 'obj/' + each
                yield objtree.Atom(ctx.objtree.find(realpath), coord, {})
        # ignore other spawners
        elif path.startswith('/obj/effect/spawner'):
            pass
        elif atom.vars.get('icon') == "'icons/obj/items_and_weapons.dmi'" and atom.vars.get('icon_state') == '"syndballoon"':
            pass
        # non-spawners are good to go
        else:
            # objects which override appearance in New()
            if path == '/obj/structure/table/wood/fancy/black':
                atom.vars['icon'] = "'icons/obj/smooth_structures/fancy_table_black.dmi'"
            elif path == '/obj/structure/table/wood/fancy':
                atom.vars['icon'] = "'icons/obj/smooth_structures/fancy_table.dmi'"
            elif path.startswith('/turf/closed/mineral'):
                atom.vars['pixel_x'] = '-4'
                atom.vars['pixel_y'] = '-4'

            yield atom

def minimap(map, tree):
    ctx = Context(map, tree)
    icon_files = {}
    images = []

    for z in map.coords_z:
        print(f"Collecting z={z + STATION_Z - 1}")
        entries = []

        for y, x in map.coords_yx:
            these_entries = []
            coord = dmm.Coordinate(x, y, z)
            for atom in atom_list(ctx, coord):
                # erase the syndicate shuttle to avoid confusing people
                if atom.path == '/area/shuttle/syndicate':
                    # pretend it's space
                    space_atom = objtree.Atom(ctx.objtree.find('turf/open/space/basic'), coord, {})
                    these_entries = [Entry(space_atom, ((x - 1) * TILE_SIZE, (y - 1) * TILE_SIZE))]
                    break

                # don't show areas
                if atom.path.startswith('/area/'):
                    continue

                # apply pure-invisibility
                if float(atom.vars.get('invisibility', '0')) >= 100:
                    continue

                # apply pixel positioning
                pixel_pos = pixel_pos_of(atom)

                # apply smoothing
                smooth_flags = 0
                # so bad: (2 | 4) -> "24"
                for each in [1, 2, 4, 8]:
                    if str(each) in atom.vars['smooth']:
                        smooth_flags |= each
                if smooth_flags & (SMOOTH_TRUE | SMOOTH_MORE):
                    these_entries.extend(smooth(ctx, atom, smooth_flags))
                else:
                    these_entries.append(Entry(atom, pixel_pos))

            entries.extend(these_entries)

        # apply layering
        print(f"Generating z={z + STATION_Z - 1}")
        entries.sort(key=layer_of)
        image = Image.new('RGBA', (TILE_SIZE * map.size.x, TILE_SIZE * map.size.y))
        for atom, (x, y) in entries:
            # apply icon, icon_state, and dir
            icon_name = dmi.unescape(atom.vars['icon'], "'")
            icon_state = dmi.unescape(atom.vars.get('icon_state', '""'))
            dir = atom.vars.get('dir')

            if icon_name in icon_files:
                icon = icon_files[icon_name]
            else:
                icon = icon_files[icon_name] = dmi.Dmi.from_file(icon_name)

            try:
                state = icon.get_state(icon_state)
            except:
                continue
            frame = state.get_frame(dir=dir).convert('RGBA')

            # apply tint
            if 'color' in atom.vars and atom.vars['color'] in COLOR_HACK:
                frame = tint(frame, COLOR_HACK[atom.vars['color']])

            y += TILE_SIZE - frame.size[1]
            bbox = [0, 0, *frame.size]
            if x < 0:
                bbox[0] -= x
                bbox[2] += x
                x = 0
            if y < 0:
                bbox[1] -= y
                bbox[3] += y
                y = 0
            image.alpha_composite(frame, (x, y), tuple(bbox))

        images.append(image)

    return images

def pixel_pos_of(atom):
    pixel_x = int(float(atom.vars.get('pixel_x', '0')))
    pixel_y = int(float(atom.vars.get('pixel_y', '0')))
    pos_x = (atom.loc.x - 1) * TILE_SIZE + pixel_x
    pos_y = (atom.loc.y - 1) * TILE_SIZE - pixel_y
    return pos_x, pos_y

# ----------
# Icon smoothing subsystem, basically a port from the DM code

N_NORTH = 2
N_SOUTH = 4
N_EAST = 16
N_WEST = 256
N_NORTHEAST = 32
N_NORTHWEST = 512
N_SOUTHEAST = 64
N_SOUTHWEST = 1024

SMOOTH_TRUE = 1  # smooth with exact specified types or just iself
SMOOTH_MORE = 2  # smooth will all subtypes thereof
SMOOTH_DIAGONAL = 4  # smooth diagonally
SMOOTH_BORDER = 8  # smooth with the borders of the map

map_edge = object()

def smooth(ctx, atom, smooth_flags):
    adjacencies = calculate_adjacencies(ctx, atom, smooth_flags)
    if smooth_flags & SMOOTH_DIAGONAL:
        return diagonal_smooth(ctx, atom, adjacencies)
    else:
        return cardinal_smooth(ctx, atom, adjacencies)

def calculate_adjacencies(ctx, atom, smooth_flags):
    if atom.vars.get('can_be_unanchored', False) and not atom.vars.get('anchored', True):
        return 0

    adjacencies = 0
    def check_one(direction, flag):
        nonlocal adjacencies
        am = find_type_in_direction(ctx, atom, direction, smooth_flags)
        if am is map_edge:
            if smooth_flags & SMOOTH_BORDER:
                adjacencies |= flag
        elif am and am.vars.get('anchored', True):
            adjacencies |= flag

    for direction in dmi.CARDINALS:
        check_one(direction, 1 << direction)

    if adjacencies & N_NORTH:
        if adjacencies & N_WEST:
            check_one(dmi.NORTHWEST, N_NORTHWEST)
        if adjacencies & N_EAST:
            check_one(dmi.NORTHEAST, N_NORTHEAST)
    if adjacencies & N_SOUTH:
        if adjacencies & N_WEST:
            check_one(dmi.SOUTHWEST, N_SOUTHWEST)
        if adjacencies & N_EAST:
            check_one(dmi.SOUTHEAST, N_SOUTHEAST)
    return adjacencies

OFFSETS = {
    dmi.NORTH: (0, -1),
    dmi.SOUTH: (0, 1),
    dmi.EAST: (1, 0),
    dmi.WEST: (-1, 0),
    dmi.NORTHEAST: (1, -1),
    dmi.NORTHWEST: (-1, -1),
    dmi.SOUTHEAST: (1, 1),
    dmi.SOUTHWEST: (-1, 1),
}

def smoothlist_contains(smoothlist, path):
    # TODO: un-hack this when the object tree is less terribad
    return path and (smoothlist.endswith(path) or path + '/obj/' in smoothlist or path + '/turf/' in smoothlist)

def find_type_in_direction(ctx, source, direction, smooth_flags):
    dx, dy = OFFSETS[direction]
    coord = dmm.Coordinate(source.loc.x + dx, source.loc.y + dy, source.loc.z)
    if coord not in ctx.map.grid:
        return map_edge

    for atom in atom_list(ctx, coord):
        smoothlist = source.vars['canSmoothWith']
        if smoothlist != 'null':
            if smooth_flags & SMOOTH_MORE:
                current = atom.type
                while current.parent:
                    if smoothlist_contains(smoothlist, current.full_path):
                        return atom
                    current = current.parent
            else:
                if smoothlist_contains(smoothlist, atom.path):
                    return atom
        else:
            if atom.path == source.path:
                return atom
    return None

def cardinal_smooth(ctx, atom, adjacencies):
    def one_name(what, f1, n1, f2, n2, f3):
        if (adjacencies & f1) and (adjacencies & f2):
            if adjacencies & f3:
                return f"{what}-f"
            else:
                return f"{what}-{n1}{n2}"
        elif adjacencies & f1:
            return f"{what}-{n1}"
        elif adjacencies & f2:
            return f"{what}-{n2}"
        else:
            return f"{what}-i"

    def one(what, *args):
        name = one_name(what, *args)
        vars = {'icon_state': dmi.escape(name)}
        if 'smooth_icon' in atom.vars:
            vars['icon'] = atom.vars['smooth_icon']
        atom2 = objtree.Atom(atom.type, atom.loc, atom.vars.new_child(vars))
        return Entry(atom2, pixel_pos_of(atom2))

    yield one("1", N_NORTH, "n", N_WEST, "w", N_NORTHWEST)
    yield one("2", N_NORTH, "n", N_EAST, "e", N_NORTHEAST)
    yield one("3", N_SOUTH, "s", N_WEST, "w", N_SOUTHWEST)
    yield one("4", N_SOUTH, "s", N_EAST, "e", N_SOUTHEAST)

def diagonal_smooth(ctx, atom, adjacencies):
    presets = {
        N_NORTH|N_WEST: ("d-se", "d-se-0"),
        N_NORTH|N_EAST: ("d-sw", "d-sw-0"),
        N_SOUTH|N_WEST: ("d-ne", "d-ne-0"),
        N_SOUTH|N_EAST: ("d-nw", "d-nw-0"),
        N_NORTH|N_WEST|N_NORTHWEST: ("d-se", "d-se-1"),
        N_NORTH|N_EAST|N_NORTHEAST: ("d-sw", "d-sw-1"),
        N_SOUTH|N_WEST|N_SOUTHWEST: ("d-ne", "d-ne-1"),
        N_SOUTH|N_EAST|N_SOUTHEAST: ("d-nw", "d-nw-1"),
    }

    if adjacencies not in presets:
        yield from cardinal_smooth(ctx, atom, adjacencies)
        return

    # baseturf
    if atom.path.startswith('/turf/closed/wall/'):
        if atom.vars['fixed_underlay'] == '"space"1':  # ew
            atom2 = objtree.Atom(ctx.objtree.find('turf/open/space/basic'), atom.loc, {})
            yield Entry(atom2, pixel_pos_of(atom))
        else:
            dx, dy = OFFSETS[flip_angle(reverse_ndir(adjacencies))]
            coord = dmm.Coordinate(atom.loc.x + dx, atom.loc.y + dy, atom.loc.z)
            for atom2 in atom_list(ctx, coord):
                if atom2.path.startswith('/turf/open/'):
                    yield Entry(atom2, pixel_pos_of(atom))
                    break
            else:
                atom2 = objtree.Atom(ctx.objtree.find('turf/open/space/basic'), atom.loc, {})
                yield Entry(atom2, pixel_pos_of(atom))

    # diagonals
    for each in presets[adjacencies]:
        vars = {'icon_state': dmi.escape(each)}
        if 'smooth_icon' in atom.vars:
            vars['icon'] = atom.vars['smooth_icon']
        atom2 = objtree.Atom(atom.type, atom.loc, atom.vars.new_child(vars))
        yield Entry(atom2, pixel_pos_of(atom2))

def reverse_ndir(adjacencies):
    return {
        N_NORTH: dmi.NORTH,
        N_SOUTH: dmi.SOUTH,
        N_WEST: dmi.WEST,
        N_EAST: dmi.EAST,
        N_NORTHWEST: dmi.NORTHWEST,
        N_NORTHEAST: dmi.NORTHEAST,
        N_SOUTHEAST: dmi.SOUTHEAST,
        N_SOUTHWEST: dmi.SOUTHWEST,
        N_NORTH|N_WEST: dmi.NORTHWEST,
        N_NORTH|N_EAST: dmi.NORTHEAST,
        N_SOUTH|N_WEST: dmi.SOUTHWEST,
        N_SOUTH|N_EAST: dmi.SOUTHEAST,
        N_NORTH|N_WEST|N_NORTHWEST: dmi.NORTHWEST,
        N_NORTH|N_EAST|N_NORTHEAST: dmi.NORTHEAST,
        N_SOUTH|N_WEST|N_SOUTHWEST: dmi.SOUTHWEST,
        N_SOUTH|N_EAST|N_SOUTHEAST: dmi.SOUTHEAST,
    }.get(adjacencies, 0)

def flip_angle(angle):
    return {
        dmi.NORTH: dmi.SOUTH,
        dmi.SOUTH: dmi.NORTH,
        dmi.EAST: dmi.WEST,
        dmi.WEST: dmi.EAST,
        dmi.NORTHWEST: dmi.SOUTHEAST,
        dmi.NORTHEAST: dmi.SOUTHWEST,
        dmi.SOUTHWEST: dmi.NORTHEAST,
        dmi.SOUTHEAST: dmi.NORTHWEST,
    }[angle]

# ----------
# Command line

if __name__ == '__main__':
    import sys, os

    tree = objtree.ObjectTree.from_file("data/objtree.xml")

    for fname in sys.argv[1:]:
        basename, _ = os.path.splitext(os.path.basename(fname))
        print(f"Preparing minimap for {basename}")

        maps = minimap(dmm.DMM.from_file(fname), tree)
        for i, image in enumerate(maps):
            print(f"Saving z={i + STATION_Z}")
            image.save(f"data/minimaps/{basename}-{i + STATION_Z}.png")
