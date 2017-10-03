# Tools for working with DreamMaker maps

import io
from collections import OrderedDict, namedtuple

TGM_HEADER = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"
ENCODING = 'utf-8'

Coordinate = namedtuple('Coordinate', ['x', 'y', 'z'])

class DMM:
    # key_length: int
    # dictionary: OrderedDict
    # size: Coordinate
    # grid: dict
    # header: str | None
    __slots__ = ['key_length', 'dictionary', 'size', 'grid', 'header']

    def __init__(self, key_length, size):
        self.key_length = key_length
        self.dictionary = OrderedDict()
        self.size = size
        self.grid = {}
        self.header = None

    @staticmethod
    def from_file(fname):
        # stream the file rather than forcing all its contents to memory
        with open(fname, 'r', encoding=ENCODING) as f:
            return _parse(iter(lambda: f.read(1), ''))

    @staticmethod
    def from_bytes(bytes):
        return _parse(bytes.decode(ENCODING))

    def to_file(self, fname, tgm = True):
        with open(fname, 'w', newline='\n', encoding=ENCODING) as f:
            (save_tgm if tgm else save_dmm)(self, f)

    def to_bytes(self, tgm = True):
        bio = io.BytesIO()
        with io.TextIOWrapper(bio, newline='\n', encoding=ENCODING) as f:
            (save_tgm if tgm else save_dmm)(self, f)
            f.flush()
            return bio.getvalue()

    @property
    def coords_zyx(self):
        for z in range(1, self.size.z + 1):
            for y in range(1, self.size.y + 1):
                for x in range(1, self.size.x + 1):
                    yield (z, y, x)

    @property
    def coords_z(self):
        return range(1, self.size.z + 1)

    @property
    def coords_yx(self):
        for y in range(1, self.size.y + 1):
            for x in range(1, self.size.x + 1):
                yield (y, x)

    def generate_new_key(self):
        return generate_new_key(self.dictionary, self.key_length)

# ----------
# dictionary helpers

# faster than get_key() on smaller dictionaries
def search_key(dictionary, data):
    for key, value in dictionary.items():
        if value == data:
            return key
    return None

# faster than search_key() on bigger dictionaries
def get_key(keys, values, data):
    try:
        return keys[values.index(data)]
    except:
        return None

# rewrites dictionary into an ordered dictionary with no unused keys
def trim_dictionary(unclean_map):
    trimmed_dict = OrderedDict()
    adjusted_grid = dict()
    key_length = unclean_map.key_length
    key = ""
    old_to_new = dict()
    used_keys = set(unclean_map.grid.values())

    for old_key, tile in unclean_map.dictionary.items():
        if old_key in used_keys:
            key = key_after(key, key_length)
            trimmed_dict[key] = tile
            old_to_new[old_key] = key

    for coord, old_key in unclean_map.grid.items():
        adjusted_grid[coord] = old_to_new[old_key]

    data = DMM(unclean_map.key_length, unclean_map.size)
    data.dictionary = trimmed_dict
    data.grid = adjusted_grid
    return data

def sort_dictionary(dictionary):
    sorted_dict = OrderedDict()
    for key in sorted(dictionary.keys(), key=key_to_num):
        sorted_dict[key] = dictionary[key]
    return sorted_dict

def generate_new_key(dictionary):
    key = next(reversed(dictionary))
    return key_after(key, len(key))

# ----------
# key handling

# Base 52 a-z A-Z dictionary for fast conversion
BASE = 52
base52 = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
base52_r = {x: i for i, x in enumerate(base52)}

def key_to_num(key):
    num = 0
    for ch in key:
        num = BASE * num + base52_r[ch]
    return num

def num_to_key(num, key_length):
    result = ''
    while num:
        result += base52[num % BASE]
        num //= BASE

    if len(result) > key_length:
        raise KeyTooLarge()

    return base52[0] * (key_length - len(result)) + result

def key_after(key, key_length):
    return num_to_key(key_to_num(key) + 1, key_length)

def key_difference(keyA, keyB): # keyA - keyB
    return key_to_num(keyA) - key_to_num(keyB)

class KeyTooLarge(Exception):
    pass

# ----------
# An actual atom parser

def parse_map_atom(atom):
    try:
        i = atom.index('{')
    except ValueError:
        return atom, {}

    path, rest = atom[:i], atom[i+1:]
    vars = {}

    in_string = False
    in_name = False
    escaping = False
    current_name = ''
    current = ''
    for ch in rest:
        if escaping:
            escaping = False
            current += ch
        elif ch == '\\':
            escaping = True
        elif ch == '"':
            in_string = not in_string
            current += ch
        elif in_string:
            current += ch
        elif ch == ';':
            vars[current_name.strip()] = current.strip()
            current_name = current = ''
        elif ch == '=':
            current_name = current
            current = ''
        elif ch == '}':
            vars[current_name.strip()] = current.strip()
            break
        elif ch not in ' ':
            current += ch

    return path, vars

# ----------
# TGM writer

def save_tgm(dmm, output):
    output.write(f"{TGM_HEADER}\n")
    if dmm.header:
        output.write(f"{dmm.header}\n")

    # write dictionary in tgm format
    for key, value in dmm.dictionary.items():
        output.write(f'"{key}" = (\n')
        for idx, thing in enumerate(value):
            in_quote_block = False
            in_varedit_block = False
            for char in thing:
                if in_quote_block:
                    if char == '"':
                        in_quote_block = False
                    output.write(char)
                elif char == '"':
                    in_quote_block = True
                    output.write(char)
                elif not in_varedit_block:
                    if char == "{":
                        in_varedit_block = True
                        output.write("{\n\t")
                    else:
                        output.write(char)
                elif char == ";":
                    output.write(";\n\t")
                elif char == "}":
                    output.write("\n\t}")
                    in_varedit_block = False
                else:
                    output.write(char)
            if idx < len(value) - 1:
                output.write(",\n")
        output.write(")\n")

    # thanks to YotaXP for finding out about this one
    max_x, max_y, max_z = dmm.size
    for z in range(1, max_z + 1):
        output.write("\n")
        for x in range(1, max_x + 1):
            output.write(f"({x},{1},{z}) = {{\"\n")
            for y in range(1, max_y):
                output.write(f"{dmm.grid[x, y, z]}\n")
            output.write(f"{dmm.grid[x, max_y, z]}\n\"}}\n")

# ----------
# DMM writer

def save_dmm(dmm, output):
    if dmm.header:
        output.write(f"{dmm.header}\n")

    # writes a tile dictionary the same way Dreammaker does
    for key, value in dmm.dictionary.items():
        output.write(f'"{key}" = ({",".join(value)})\n')

    output.write("\n")

    # writes a map grid the same way Dreammaker does
    max_x, max_y, max_z = dmm.size
    for z in range(1, max_z + 1):
        output.write(f"(1,1,{z}) = {{\"\n")

        for y in range(1, max_y + 1):
            for x in range(1, max_x + 1):
                try:
                    output.write(dmm.grid[x, y, z])
                except KeyError:
                    print(f"Key error: ({x}, {y}, {z})")
            output.write("\n")
        output.write("\"}\n")

# ----------
# Parser

def _parse(map_raw_text):
    in_comment_line = False
    comment_trigger = False

    in_quote_block = False
    in_key_block = False
    in_data_block = False
    in_varedit_block = False
    after_data_block = False
    escaping = False
    skip_whitespace = False

    dictionary = OrderedDict()
    curr_key = ""
    curr_datum = ""
    curr_data = list()

    in_map_block = False
    in_coord_block = False
    in_map_string = False
    iter_x = 0
    adjust_y = True

    curr_num = ""
    reading_coord = "x"

    key_length = 0

    maxx = 0
    maxy = 0
    maxz = 0

    curr_x = 0
    curr_y = 0
    curr_z = 0
    grid = dict()

    for char in map_raw_text:

        if not in_map_block:

            if char == "\n":
                in_comment_line = False
                comment_trigger = False
                continue

            if in_comment_line:
                continue

            if char == "\t":
                continue

            if char == "/" and not in_quote_block:
                if comment_trigger:
                    in_comment_line = True
                    continue
                else:
                    comment_trigger = True
            else:
                comment_trigger = False

            if in_data_block:

                if in_varedit_block:

                    if in_quote_block:
                        if char == "\\":
                            curr_datum = curr_datum + char
                            escaping = True
                            continue

                        if escaping:
                            curr_datum = curr_datum + char
                            escaping = False
                            continue

                        if char == "\"":
                            curr_datum = curr_datum + char
                            in_quote_block = False
                            continue

                        curr_datum = curr_datum + char
                        continue

                    if skip_whitespace and char == " ":
                        skip_whitespace = False
                        continue
                    skip_whitespace = False

                    if char == "\"":
                        curr_datum = curr_datum + char
                        in_quote_block = True
                        continue

                    if char == ";":
                        skip_whitespace = True
                        curr_datum = curr_datum + char
                        continue

                    if char == "}":
                        curr_datum = curr_datum + char
                        in_varedit_block = False
                        continue

                    curr_datum = curr_datum + char
                    continue

                if char == "{":
                    curr_datum = curr_datum + char
                    in_varedit_block = True
                    continue

                if char == ",":
                    curr_data.append(curr_datum)
                    curr_datum = ""
                    continue

                if char == ")":
                    curr_data.append(curr_datum)
                    dictionary[curr_key] = tuple(curr_data)
                    curr_data = list()
                    curr_datum = ""
                    curr_key = ""
                    in_data_block = False
                    after_data_block = True
                    continue

                curr_datum = curr_datum + char
                continue

            if in_key_block:
                if char == "\"":
                    in_key_block = False
                    if key_length == 0:
                        key_length = len(curr_key)
                    else:
                        assert key_length == len(curr_key)
                else:
                    curr_key = curr_key + char
                continue
            #else we're looking for a key block, a data block or the map block

            if char == "\"":
                in_key_block = True
                after_data_block = False
                continue

            if char == "(":
                if after_data_block:
                    in_map_block = True
                    in_coord_block = True
                    after_data_block = False
                    curr_key = ""
                    continue
                else:
                    in_data_block = True
                    after_data_block = False
                    continue

        else:

            if in_coord_block:
                if char == ",":
                    if reading_coord == "x":
                        curr_x = int(curr_num)
                        if curr_x > maxx:
                            maxx = curr_x
                        iter_x = 0
                        curr_num = ""
                        reading_coord = "y"
                    elif reading_coord == "y":
                        curr_y = int(curr_num)
                        if curr_y > maxy:
                            maxy = curr_y
                        curr_num = ""
                        reading_coord = "z"
                    else:
                        pass
                    continue

                if char == ")":
                    curr_z = int(curr_num)
                    if curr_z > maxz:
                        maxz = curr_z
                    in_coord_block = False
                    reading_coord = "x"
                    curr_num = ""
                    continue

                curr_num = curr_num + char
                continue

            if in_map_string:

                if char == "\"":
                    in_map_string = False
                    adjust_y = True
                    curr_y -= 1
                    continue

                if char == "\n":
                    if adjust_y:
                        adjust_y = False
                    else:
                        curr_y += 1
                    if curr_x > maxx:
                        maxx = curr_x
                    if iter_x > 1:
                        curr_x = 1
                    iter_x = 0
                    continue

                curr_key = curr_key + char
                if len(curr_key) == key_length:
                    iter_x += 1
                    if iter_x > 1:
                        curr_x += 1

                    grid[curr_x, curr_y, curr_z] = curr_key
                    curr_key = ""
                continue


            #else look for coordinate block or a map string

            if char == "(":
                in_coord_block = True
                continue
            if char == "\"":
                in_map_string = True
                continue

    if curr_y > maxy:
        maxy = curr_y

    data = DMM(key_length, Coordinate(maxx, maxy, maxz))
    data.dictionary = dictionary
    data.grid = grid
    return data
