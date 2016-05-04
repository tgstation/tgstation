#!/usr/bin/env python3
import argparse
import collections
import re

## I stole these functions from map_helpers.py on commit 09b6caeb0e3

def parse_map(map_file):
    maxx = 0
    maxy = 0
    key_length = 1
    with open(map_file, "r") as map_input:
        characters = map_input.read()

        in_quote_block = False
        in_key_block = False
        in_data_block = False
        in_varedit_block = False
        after_data_block = False
        escaping = False
        skip_whitespace = False

        dictionary = collections.OrderedDict()
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

        curr_x = 0
        curr_y = 0
        curr_z = 1
        grid = dict()

        for char in characters:

            if not in_map_block:

                if char == "\n" or char == "\t":
                    continue

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
                        key_length = len(curr_key)
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
                            curr_x = string_to_num(curr_num)
                            if curr_x > maxx:
                                maxx = curr_x
                            iter_x = 0
                            curr_num = ""
                            reading_coord = "y"
                        elif reading_coord == "y":
                            curr_y = string_to_num(curr_num)
                            if curr_y > maxy:
                                maxy = curr_y
                            curr_num = ""
                            reading_coord = "z"
                        else:
                            pass
                        continue

                    if char == ")":
                        in_coord_block = False
                        reading_coord = "x"
                        curr_num = ""
                        #read z here if needed
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

                        grid[curr_x, curr_y] = curr_key
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

        data = dict()
        data["dictionary"] = dictionary
        data["grid"] = grid
        return data

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("mapfile")

    args = parser.parse_args()
    M = parse_map(args.mapfile)
    # Format of this map parsing
    # dict(coordinates->mapkey)
    grid = M["grid"]
    # dict(mapkey->tilecontents)
    dictionary = M["dictionary"]
    # tilecontents are a list of atoms, path is first

    lootdrop_path = "/obj/effect/spawner/lootdrop/maintenance"
    area_path = "/area"

    follow_up = set()
    for key, atoms in dictionary.items():
        #atom is a string
        for atom in atoms:
            if atom.startswith(lootdrop_path):
                follow_up.add(key)

    # Count the number of times each map key appears
    appears = collections.Counter()
    for coord, key in grid.items():
        if key in follow_up:
            appears[key] += 1

    tally = collections.Counter()
    for key in follow_up:
        # Because I am a terrible person, and don't actually care about
        # building a proper parser for this "object notation" that byond
        # uses, I'm just going to cheat.
        area = None
        count = 0

        for atom in dictionary[key]:
            if atom.startswith(lootdrop_path):
                amount = 1
                mo = re.search(r'lootcount = (\d+)', atom)
                if mo is not None:
                    amount = int(mo.group(1))
                count += amount

            elif atom.startswith(area_path):
                area = atom

        # Multiply by the number of times this model is used
        tally[area] += (count * appears[key])

    for area, total in tally.items():
        print("{}: {}".format(area, total))
