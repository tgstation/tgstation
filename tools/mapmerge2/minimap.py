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

Context = namedtuple('Context', ['map', 'objtree', 'prefabs', 'prefabs2'])

def simple_layer(atom):
    layer = atom['layer']
    return float(DEFINES.get(layer, layer))

def layer_of(atom):
    ty = atom.type
    if ty.subtype_of('/turf/open/floor/plating') or ty.subtype_of('/turf/open/space'):
        return -10  # under everything
    elif ty.subtype_of('/turf/closed/mineral'):
        return -3   # above hidden stuff and plating but below walls
    elif ty.subtype_of('/turf/open/floor') or ty.subtype_of('/turf/closed'):
        return -2   # above hidden pipes and wires
    elif ty.subtype_of('/turf'):
        return -10  # under everything
    elif ty.subtype_of('/obj/effect/turf_decal'):
        return -1   # above turfs
    elif ty.subtype_of('/obj/structure/disposalpipe'):
        return -6
    elif ty.subtype_of('/obj/machinery/atmospherics/pipe') and 'hidden' in ty.path.split('/'):
        return -5
    elif ty.subtype_of('/obj/structure/cable'):
        return -4
    elif ty.subtype_of('/obj/structure/lattice'):
        return -8
    elif ty.subtype_of('/area'):
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

def parse_prefabs(ctx, dict_entry):
    items = []
    for entry in dict_entry:
        try:
            items.append(ctx.prefabs2[entry])
        except KeyError:
            path, vars = dmm.parse_map_atom(entry)
            prefab = ctx.prefabs2[entry] = objtree.Prefab(ctx.objtree[path], vars)
            items.append(prefab)
    return items

def atom_list(ctx, coord):
    grid = ctx.map.grid[coord]
    try:
        prefabs = ctx.prefabs[grid]
    except KeyError:
        prefabs = ctx.prefabs[grid] = parse_prefabs(ctx, ctx.map.dictionary[grid])

    for entry in prefabs:
        atom = entry.new(coord)
        ty = atom.type

        # apply window spawners
        if ty.subtype_of('/obj/effect/spawner/structure'):
            # TODO: unhack this when the objtree is less bad
            for each in atom['spawn_list'].split('/obj/'):
                if not each: continue
                realpath = 'obj/' + each
                yield ctx.objtree.new('/obj/' + each, coord)
        # ignore other spawners
        elif ty.subtype_of('/obj/effect/spawner'):
            pass
        elif atom['icon'] == "'icons/obj/items_and_weapons.dmi'" and atom['icon_state'] == '"syndballoon"':
            pass
        # non-spawners are good to go
        else:
            # objects which override appearance in New()
            if ty.path == '/obj/structure/table/wood/fancy/black':
                atom['icon'] = "'icons/obj/smooth_structures/fancy_table_black.dmi'"
            elif ty.path == '/obj/structure/table/wood/fancy':
                atom['icon'] = "'icons/obj/smooth_structures/fancy_table.dmi'"
            elif ty.subtype_of('/turf/closed/mineral'):
                atom['pixel_x'] = '-4'
                atom['pixel_y'] = '-4'

            yield atom

def collect(ctx, x, y, z):
    atoms = []
    coord = dmm.Coordinate(x, y, z)
    for atom in atom_list(ctx, coord):
        # erase the syndicate shuttle by pretending it's space
        if atom.type.path == '/area/shuttle/syndicate':
            return [ctx.objtree.new('/turf/open/space/basic', coord)]

        # don't show areas
        if atom.type.subtype_of('/area'):
            continue

        # apply pure-invisibility
        if float(atom.get('invisibility', '0')) >= 100:
            continue

        # apply smoothing
        smooth_flags = 0
        # so bad: (2 | 4) -> "24"
        for each in [1, 2, 4, 8]:
            if str(each) in atom['smooth']:
                smooth_flags |= each
        if smooth_flags & (SMOOTH_TRUE | SMOOTH_MORE):
            atoms.extend(smooth(ctx, atom, smooth_flags))
        else:
            atoms.append(atom)

        # apply overlayering
        if atom.type.subtype_of('/obj/structure/closet'):
            door = atom.get('icon_door')
            if door is None or door == 'null':
                door = atom['icon_state']
            copy = atom.copy()
            copy['icon_state'] = dmi.escape(dmi.unescape(door) + '_door')
            atoms.append(copy)
        elif atom.type.subtype_of('/obj/machinery/computer'):
            screen = atom.get('icon_screen')
            if screen is not None and screen != 'null':
                copy = atom.copy()
                copy['icon_state'] = screen
                atoms.append(copy)
            keyboard = atom.get('icon_keyboard')
            if keyboard is not None and keyboard != 'null':
                copy = atom.copy()
                copy['icon_state'] = keyboard
                atoms.append(copy)
        elif atom.type.subtype_of('/obj/structure/transit_tube'):
            atoms.extend(generate_tube_overlays(ctx, atom))

    return atoms

def generate(ctx, icon_files, atoms):
    image = Image.new('RGBA', (TILE_SIZE * ctx.map.size.x, TILE_SIZE * ctx.map.size.y))
    for atom in atoms:
        # apply icon, icon_state, and dir
        icon_name = dmi.unescape(atom['icon'], "'")
        icon_state = dmi.unescape(atom.get('icon_state', '""'))
        dir = atom.get('dir')

        try:
            icon = icon_files[icon_name]
        except KeyError:
            icon = icon_files[icon_name] = dmi.Dmi.from_file(icon_name)

        try:
            state = icon.get_state(icon_state)
        except:
            continue
        frame = state.get_frame(dir=dir).convert('RGBA')

        # apply tint
        try:
            color = COLOR_HACK[atom['color']]
        except KeyError:
            pass
        else:
            frame = tint(frame, color)

        # apply pixel location
        pixel_x = int(float(atom.get('pixel_x', '0')))
        pixel_y = int(float(atom.get('pixel_y', '0')))
        x = (atom.loc.x - 1) * TILE_SIZE + pixel_x
        y = (atom.loc.y) * TILE_SIZE - pixel_y - frame.size[1]
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
    return image

def minimap(map, tree):
    ctx = Context(map, tree, {}, {})
    icon_files = {}
    images = []

    for z in map.coords_z:
        print(f"Collecting z={z + STATION_Z - 1}")
        atoms = []

        for y, x in map.coords_yx:
            atoms.extend(collect(ctx, x, y, z))

        print(f"Generating z={z + STATION_Z - 1}")
        atoms.sort(key=layer_of)
        images.append(generate(ctx, icon_files, atoms))

    return images

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
    if atom.get('can_be_unanchored', False) and not atom.get('anchored', True):
        return 0

    adjacencies = 0
    def check_one(direction, flag):
        nonlocal adjacencies
        am = find_type_in_direction(ctx, atom, direction, smooth_flags)
        if am is map_edge:
            if smooth_flags & SMOOTH_BORDER:
                adjacencies |= flag
        elif am and am.get('anchored', True):
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
        smoothlist = source['canSmoothWith']
        if smoothlist != 'null':
            if smooth_flags & SMOOTH_MORE:
                current = atom.type
                while current.parent:
                    if smoothlist_contains(smoothlist, current.path):
                        return atom
                    current = current.parent
            else:
                if smoothlist_contains(smoothlist, atom.type.path):
                    return atom
        else:
            if atom.type == source.type:
                return atom
    return None

def cardinal_smooth(ctx, atom, adjacencies):
    for what, f1, n1, f2, n2, f3 in [
        ("1", N_NORTH, "n", N_WEST, "w", N_NORTHWEST),
        ("2", N_NORTH, "n", N_EAST, "e", N_NORTHEAST),
        ("3", N_SOUTH, "s", N_WEST, "w", N_SOUTHWEST),
        ("4", N_SOUTH, "s", N_EAST, "e", N_SOUTHEAST),
    ]:
        if (adjacencies & f1) and (adjacencies & f2):
            if adjacencies & f3:
                name = f"{what}-f"
            else:
                name = f"{what}-{n1}{n2}"
        elif adjacencies & f1:
            name = f"{what}-{n1}"
        elif adjacencies & f2:
            name = f"{what}-{n2}"
        else:
            name = f"{what}-i"

        copy = atom.copy()
        copy['icon_state'] = dmi.escape(name)
        try:
            copy['icon'] = atom['smooth_icon']
        except KeyError:
            pass
        yield copy

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
    if atom.type.subtype_of('/turf/closed/wall'):
        if atom['fixed_underlay'] == '"space"1':  # ew
            yield ctx.objtree.new('/turf/open/space/basic', atom.loc)
        else:
            dx, dy = OFFSETS[flip_angle(reverse_ndir(adjacencies))]
            coord = dmm.Coordinate(atom.loc.x + dx, atom.loc.y + dy, atom.loc.z)
            for atom2 in atom_list(ctx, coord):
                if atom2.type.subtype_of('/turf/open'):
                    atom2.loc = atom.loc
                    yield atom2
                    break
            else:
                yield ctx.objtree.new('/turf/open/space/basic', atom.loc)

    # diagonals
    for each in presets[adjacencies]:
        copy = atom.copy()
        copy['icon_state'] = dmi.escape(each)
        try:
            copy['icon'] = atom['smooth_icon']
        except KeyError:
            pass
        yield copy

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

def generate_tube_overlays(ctx, atom):
    tube_dirs = {
        '': {
            dmi.NORTH: [dmi.NORTH, dmi.SOUTH],
            dmi.SOUTH: [dmi.NORTH, dmi.SOUTH],
            dmi.EAST: [dmi.EAST, dmi.WEST],
            dmi.WEST: [dmi.EAST, dmi.WEST],
        },
        '/diagonal': {
            dmi.NORTH: [dmi.NORTHEAST, dmi.SOUTHWEST],
            dmi.SOUTH: [dmi.NORTHEAST, dmi.SOUTHWEST],
            dmi.EAST: [dmi.NORTHWEST, dmi.SOUTHEAST],
            dmi.WEST: [dmi.NORTHWEST, dmi.SOUTHEAST],
        },
        '/curved': {
            dmi.NORTH: [dmi.NORTH, dmi.SOUTHWEST],
            dmi.SOUTH: [dmi.SOUTH, dmi.NORTHEAST],
            dmi.EAST: [dmi.EAST, dmi.NORTHWEST],
            dmi.WEST: [dmi.SOUTHEAST, dmi.WEST],
        },
        '/curved/flipped': {
            dmi.NORTH: [dmi.NORTH, dmi.SOUTHEAST],
            dmi.SOUTH: [dmi.SOUTH, dmi.NORTHWEST],
            dmi.EAST: [dmi.EAST, dmi.SOUTHWEST],
            dmi.WEST: [dmi.NORTHEAST, dmi.WEST],
        },
        '/junction': {
            dmi.NORTH: [dmi.NORTH, dmi.SOUTHEAST, dmi.SOUTHWEST],
            dmi.SOUTH: [dmi.SOUTH, dmi.NORTHWEST, dmi.NORTHEAST],
            dmi.EAST: [dmi.EAST, dmi.SOUTHWEST, dmi.NORTHWEST],
            dmi.WEST: [dmi.WEST, dmi.NORTHEAST, dmi.SOUTHEAST],
        },
        '/junction/flipped': {
            dmi.NORTH: [dmi.NORTH, dmi.SOUTHWEST, dmi.SOUTHEAST],
            dmi.SOUTH: [dmi.SOUTH, dmi.NORTHEAST, dmi.NORTHWEST],
            dmi.EAST: [dmi.EAST, dmi.SOUTHEAST, dmi.NORTHEAST],
            dmi.WEST: [dmi.WEST, dmi.NORTHWEST, dmi.SOUTHWEST],
        },
        '/station': {
            dmi.NORTH: [dmi.EAST, dmi.WEST],
            dmi.SOUTH: [dmi.EAST, dmi.WEST],
            dmi.EAST: [dmi.NORTH, dmi.SOUTH],
            dmi.WEST: [dmi.NORTH, dmi.SOUTH],
        },
        '/station/reverse': {
            dmi.NORTH: [dmi.EAST],
            dmi.SOUTH: [dmi.WEST],
            dmi.EAST: [dmi.SOUTH],
            dmi.WEST: [dmi.NORTH],
        },
    }

    path = atom.type.path[len('/obj/structure/transit_tube'):]
    while path not in tube_dirs:
        path = path[:path.rindex('/')]
    print(atom)
    dir = atom.get('dir', 'SOUTH')
    tube_dirs = tube_dirs[path][dmi.DIR_NAMES.get(dir, dir)]

    for direction in tube_dirs:
        if direction in (dmi.NORTHEAST, dmi.NORTHWEST, dmi.SOUTHEAST, dmi.SOUTHWEST):
            if direction & dmi.NORTH:
                yield create_tube_overlay(ctx, atom, direction ^ 3, dmi.NORTH)
                if direction & dmi.EAST:
                    yield create_tube_overlay(ctx, atom, direction ^ 12, dmi.EAST)
                else:
                    yield create_tube_overlay(ctx, atom, direction ^ 12, dmi.WEST)
        else:
            yield create_tube_overlay(ctx, atom, direction)

def create_tube_overlay(ctx, atom, direction, shift_dir=None):
    copy = objtree.Atom(ctx.objtree.root, atom.loc)
    copy['dir'] = direction
    copy['layer'] = atom['layer']
    copy['icon'] = atom['icon']
    if shift_dir:
        copy['icon_state'] = '"decorative_diag"'
        if shift_dir == dmi.NORTH:
            copy['pixel_y'] = 32
        elif shift_dir == dmi.SOUTH:
            copy['pixel_y'] = -32
        elif shift_dir == dmi.EAST:
            copy['pixel_x'] = 32
        elif shift_dir == dmi.WEST:
            copy['pixel_x'] = -32
    else:
        copy['icon_state'] = '"decorative"'
    return copy

# ----------
# Command line

if __name__ == '__main__':
    import sys, os

    tree = objtree.ObjectTree.from_file("data/objtree.xml")
    tree._bake()

    for fname in sys.argv[1:]:
        basename, _ = os.path.splitext(os.path.basename(fname))
        print(f"Preparing minimap for {basename}")

        maps = minimap(dmm.DMM.from_file(fname), tree)
        for i, image in enumerate(maps):
            print(f"Saving z={i + STATION_Z}")
            image.save(f"data/minimaps/{basename}-{i + STATION_Z}.png")
