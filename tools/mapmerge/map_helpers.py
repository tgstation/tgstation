import sys
import subprocess
from datetime import datetime

tgm_header = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"

try:
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 5):
        print("ERROR: You are running an incompatible version of Python. The current minimum version required is [3.5].\nYour version: {}".format(sys.version))
        sys.exit()
except:
    print("ERROR: Something went wrong, you might be running an incompatible version of Python. The current minimum version required is [3.5].\nYour version: {}".format(sys.version))
    sys.exit()

import collections

error = {0:"OK", 1:"WARNING: Detected key length difference, not merging.", 2:"WARNING: Detected map size difference, not merging."}

def merge_map(newfile, backupfile, tgm):
    key_length = 1
    maxx = 1
    maxy = 1

    new_map = parse_map(get_map_raw_text(newfile))
    old_map = parse_map(get_map_raw_text(backupfile))

    if new_map["key_length"] != old_map["key_length"]:
        if tgm:
            write_dictionary_tgm(newfile, new_map["dictionary"])
            write_grid_coord_small(newfile, new_map["grid"], new_map["maxx"], new_map["maxy"])
        return 1
    else:
        key_length = old_map["key_length"]

    if new_map["maxx"] != old_map["maxx"] or new_map["maxy"] != old_map["maxy"]:
        if tgm:
            write_dictionary_tgm(newfile, new_map["dictionary"])
            write_grid_coord_small(newfile, new_map["grid"], new_map["maxx"], new_map["maxy"])
        return 2
    else:
        maxx = old_map["maxx"]
        maxy = old_map["maxy"]

    new_dict = new_map["dictionary"]
    new_grid = new_map["grid"]
    old_dict = sort_dictionary(old_map["dictionary"]) #impose order; old_dict is used in the end as the merged dictionary
    old_grid = old_map["grid"]

    merged_grid = dict()
    known_keys = dict()
    unused_keys = list(old_dict.keys())

    #both new and old dictionary in lists, for faster key lookup by tile tuple
    old_dict_keys = list(old_dict.keys())
    old_dict_values = list(old_dict.values())
    new_dict_keys = list(new_dict.keys())
    new_dict_values = list(new_dict.values())

    #step one: parse the new version, compare it to the old version, merge both
    for y in range(1, maxy+1):
        for x in range(1, maxx+1):

            new_key = new_grid[x,y]
            #if this key has been processed before, it can immediately be merged
            if new_key in known_keys:
                merged_grid[x,y] = known_keys[new_key]
                continue

            old_key = old_grid[x,y]
            old_tile = old_dict[old_key]
            new_tile = new_dict[new_key]
            
            if new_tile == old_tile: #this tile is the exact same as before, so the old key is used
                merged_grid[x,y] = old_key
                known_keys[new_key] = old_key
                unused_keys.remove(old_key)
                continue

            #the tile is different here, but if it exists in the old dictionary, its old key can be used
            newold_key = get_key(old_dict_keys, old_dict_values, new_tile) 
            if newold_key != None:
                merged_grid[x,y] = newold_key
                known_keys[new_key] = newold_key
                try:
                    unused_keys.remove(newold_key)
                except ValueError:
                    print("NOTICE: Correcting duplicate dictionary entry. ({})".format(new_key))

            #the tile is brand new and it needs a new key, but if the old key isn't being used any longer it can be used instead
            elif get_key(new_dict_keys, new_dict_values, old_tile) == None:
                merged_grid[x,y] = old_key
                old_dict[old_key] = new_tile
                known_keys[new_key] = old_key
                unused_keys.remove(old_key)

            #all other options ruled out, a brand new key is generated for the brand new tile
            else: 
                fresh_key = generate_new_key(old_dict)
                old_dict[fresh_key] = new_tile
                merged_grid[x,y] = fresh_key

    header = False
    #step two: clean the dictionary if it has too many unused keys
    if len(unused_keys) > min(1600, (len(old_dict) * 0.5)):
        print("NOTICE: Trimming the dictionary.")
        trimmed_dict_map = trim_dictionary({"dictionary": old_dict, "grid": merged_grid})
        old_dict = trimmed_dict_map["dictionary"]
        merged_grid = trimmed_dict_map["grid"]
        print("NOTICE: Trimmed out {} unused dictionary keys.".format(len(unused_keys)))
        header = "//Model dictionary trimmed on: {}".format(datetime.utcnow().strftime("%d-%m-%Y %H:%M (UTC)"))

    #step three: write the map to file
    if tgm:
        write_dictionary_tgm(newfile, old_dict, header)
        write_grid_coord_small(newfile, merged_grid, maxx, maxy)
    else:
        write_dictionary(newfile, old_dict, header)
        write_grid(newfile, merged_grid, maxx, maxy)
    return 0

#######################
#write to file helpers#
def write_dictionary_tgm(filename, dictionary, header = None): #write dictionary in tgm format
    with open(filename, "w") as output:
        output.write("{}\n".format(tgm_header))
        if header:
            output.write("{}\n".format(header))
        for key, list_ in dictionary.items():
            output.write("\"{}\" = (\n".format(key))

            for thing in list_:
                buffer = ""
                in_quote_block = False
                in_varedit_block = False
                for char in thing:
                    
                    if in_quote_block:
                        if char == "\"":
                            in_quote_block = False
                        buffer = buffer + char
                        continue
                    elif char == "\"":
                        in_quote_block = True
                        buffer = buffer + char
                        continue

                    if not in_varedit_block:
                        if char == "{":
                            in_varedit_block = True
                            buffer = buffer + "{\n\t"
                            continue
                    else:
                        if char == ";":
                            buffer = buffer + ";\n\t"
                            continue
                        elif char == "}":
                            buffer = buffer + "\n\t}"
                            in_varedit_block = False
                            continue

                    buffer = buffer + char
                
                if list_.index(thing) != len(list_) - 1:
                    buffer = buffer + ",\n"
                output.write(buffer)
                        
            output.write(")\n")


def write_grid_coord_small(filename, grid, maxx, maxy): #thanks to YotaXP for finding out about this one
    with open(filename, "a") as output:
        output.write("\n")

        for x in range(1, maxx+1):
            output.write("({},{},1) = {{\"\n".format(x, 1, 1))
            for y in range(1, maxy):
                output.write("{}\n".format(grid[x,y]))
            output.write("{}\n\"}}\n".format(grid[x,maxy]))


def write_dictionary(filename, dictionary, header = None): #writes a tile dictionary the same way Dreammaker does
    with open(filename, "w") as output:
        for key, value in dictionary.items():
            if header:
                output.write("{}\n".format(header))
            output.write("\"{}\" = ({})\n".format(key, ",".join(value)))


def write_grid(filename, grid, maxx, maxy): #writes a map grid the same way Dreammaker does
    with open(filename, "a") as output:
        output.write("\n")
        output.write("(1,1,1) = {\"\n")

        for y in range(1, maxy+1):
            for x in range(1, maxx+1):
                try:
                    output.write(grid[x,y])
                except KeyError:
                    print("Key error: ({},{})".format(x,y))
            output.write("\n")
        output.write("\"}")
        output.write("\n")

####################
#dictionary helpers#

#faster than get_key() on smaller dictionaries
def search_key(dictionary, data):
    for key, value in dictionary.items():
        if value == data:
            return key
    return None

#faster than search_key() on bigger dictionaries
def get_key(keys, values, data): 
    try:
        return keys[values.index(data)]
    except:
        return None

def trim_dictionary(unclean_map): #rewrites dictionary into an ordered dictionary with no unused keys
    trimmed_dict = collections.OrderedDict()
    adjusted_grid = dict()
    key_length = len(list(unclean_map["dictionary"].keys())[0])
    key = ""
    old_to_new = dict()
    used_keys = set(unclean_map["grid"].values())

    for old_key, tile in unclean_map["dictionary"].items():
        if old_key in used_keys:
            key = get_next_key(key, key_length)
            trimmed_dict[key] = tile
            old_to_new[old_key] = key

    for coord, old_key in unclean_map["grid"].items():
        adjusted_grid[coord] = old_to_new[old_key]

    return {"dictionary": trimmed_dict, "grid": adjusted_grid}

def sort_dictionary(dictionary):
    sorted_dict = collections.OrderedDict()
    keys = list(dictionary.keys())
    keys.sort(key=key_int_value)
    for key in keys:
        sorted_dict[key] = dictionary[key]
    return sorted_dict

############
#map parser#
def get_map_raw_text(mapfile):
    with open(mapfile, "r") as reading:
        return reading.read()

def parse_map(map_raw_text): #still does not support more than one z level per file, but should parse any format
    in_comment_line = False
    comment_trigger = False

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

    key_length = 0
        
    maxx = 0
    maxy = 0
        
    curr_x = 0
    curr_y = 0
    curr_z = 1
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
    data["key_length"] = key_length
    data["maxx"] = maxx
    data["maxy"] = maxy
    return data

#############
#key helpers#
def generate_new_key(dictionary):
    last_key = next(reversed(dictionary))
    return get_next_key(last_key, len(last_key))

def get_next_key(key, key_length):
    if key == "":
        return "".join("a" for _ in range(key_length))

    length = len(key)
    new_key = ""
    carry = 1
    for char in key[::-1]:
        if carry <= 0:
            new_key = new_key + char
            continue
        if char == 'Z':
            new_key = new_key + 'a'
            carry += 1
            length -= 1
            if length <= 0:
                return "OVERFLOW"
        elif char == 'z':
            new_key = new_key + 'A'
        else:
            new_key = new_key + chr(ord(char) + 1)
        if carry > 0:
            carry -= 1
    return new_key[::-1]

def key_int_value(key):
    value = 0
    b = 0
    for digit in reversed(key):
        value += base52.index(digit) * (52 ** b)
        b += 1
    return value

def key_compare(keyA, keyB): #thanks byond for not respecting ascii
    pos = 0
    for a in keyA:
        pos += 1
        count = pos
        for b in keyB:
            if(count > 1):
                count -= 1
                continue
            if a.islower() and b.islower():
                if(a < b):
                    return -1
                if(a > b):
                    return 1
                break
            if a.islower() and b.isupper():
                return -1
            if a.isupper() and b.islower():
                return 1
            if a.isupper() and b.isupper():
                if(a < b):
                    return -1
                if(a > b):
                    return 1
                break
    return 0


def key_difference(keyA, keyB): #subtract keyB from keyA
    if len(keyA) != len(keyB):
        return "you fucked up"

    Ayek = keyA[::-1]
    Byek = keyB[::-1]

    result = 0
    for i in range(0, len(keyA)):
        base = 52**i
        A = 26 if Ayek[i].isupper() else 0
        B = 26 if Byek[i].isupper() else 0
        result += ( (ord(Byek[i].lower()) + B) - (ord(Ayek[i].lower()) + A) ) * base
    return result

#############
#other stuff#

#Base 52 a-z A-Z dictionary (it's a python list) for fast conversion
base52 = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o',
             'p','q','r','s','t','u','v','w','x','y','z','A','B','C','D',
             'E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S',
             'T','U','V','W','X','Y','Z']

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

####################
#map conflict fixer#

MAP_FIX_DICTIONARY = 0
MAP_FIX_FULL = 1
MAP_FIX_PRIORITY_OURS = 0
MAP_FIX_PRIORITY_THEIRS = 1

def fix_map_git_conflicts(base_map, ours_map, theirs_map, mode, marker, priority, path): #attempts to fix git map conflicts automagically
    #mode values:
    # 0 - Dictionary mode, only fixes dictionary conflicts and fails at coordinate conflicts
    # 1 - Full mode, fixes dictionary conflicts and will join both versions of a coordinate and adds a marker to each conflicted coordinate

    if mode == MAP_FIX_FULL and not marker:
        print("ERROR: Full fix mode selected but a marker wasn't provided.")
        return False
    
    key_length = 1
    maxx = 1
    maxy = 1
    
    if ours_map["key_length"] != theirs_map["key_length"] or ours_map["key_length"] != base_map["key_length"]:
        print("ERROR: Key length is different, I am not smart enough for this yet.")
        return False
    else:
        key_length = ours_map["key_length"]

    if ours_map["maxx"] != theirs_map["maxx"] or ours_map["maxy"] != theirs_map["maxy"] or ours_map["maxx"] != base_map["maxx"] or ours_map["maxy"] != base_map["maxy"]:
        print("ERROR: Map size is different, I am not smart enough for this yet.")
        return False
    else:
        maxx = ours_map["maxx"]
        maxy = ours_map["maxy"]

    base_dict = base_map["dictionary"]
    base_grid = base_map["grid"]
    ours_dict = ours_map["dictionary"]
    ours_grid = ours_map["grid"]
    theirs_dict = theirs_map["dictionary"]
    theirs_grid = theirs_map["grid"]

    merged_dict = collections.OrderedDict()
    merged_grid = dict()

    new_key = generate_new_key(base_dict)

    grid_conflict_counter = 0

    for y in range(1, maxy+1):
        for x in range(1, maxx+1):
            base_key = base_grid[x,y]
            ours_key = ours_grid[x,y]
            theirs_key = theirs_grid[x,y]

            #case 1: everything is the same
            if base_dict[base_key] == ours_dict[ours_key] and base_dict[base_key] == theirs_dict[theirs_key]:
                merged_dict[base_key] = base_dict[base_key]
                merged_grid[x,y] = base_key
                continue

            #case 2: ours is unchanged, theirs is different
            if base_dict[base_key] == ours_dict[ours_key]:
                some_key = search_key(base_dict, theirs_dict[theirs_key])
                if some_key != None:
                    merged_dict[some_key] = theirs_dict[theirs_key]
                    merged_grid[x,y] = some_key
                else:
                    merged_dict[new_key] = theirs_dict[theirs_key]
                    merged_grid[x,y] = new_key
                    new_key = get_next_key(new_key, key_length)

            #case 3: ours is different, theirs is unchanged
            elif base_dict[base_key] == theirs_dict[theirs_key]:
                some_key = search_key(base_dict, ours_dict[ours_key])
                if some_key != None:
                    merged_dict[some_key] = ours_dict[ours_key]
                    merged_grid[x,y] = some_key
                else:
                    merged_dict[new_key] = ours_dict[ours_key]
                    merged_grid[x,y] = new_key
                    new_key = get_next_key(new_key, key_length)

            #case 4: everything is different, grid conflict
            else:
                if mode != MAP_FIX_FULL:
                    print("FAILED: Map fixing failed due to grid conflicts. Try fixing in full fix mode.")
                    return False
                else:
                    combined_tile = combine_tiles(ours_dict[ours_key], theirs_dict[theirs_key], priority, marker)
                    merged_dict[new_key] = combined_tile
                    merged_grid[x,y] = new_key
                    new_key = get_next_key(new_key, key_length)
                    grid_conflict_counter += 1

    merged_dict = sort_dictionary(merged_dict)
    write_dictionary_tgm(path+".fixed.dmm", merged_dict)
    write_grid_coord_small(path+".fixed.dmm", merged_grid, maxx, maxy)
    if grid_conflict_counter > 0:
        print("Counted {} conflicts.".format(grid_conflict_counter))
    return True

def combine_tiles(tile_A, tile_B, priority, marker):
    new_tile = list()
    turf_atom = None
    area_atom = None

    low_tile = None
    high_tile = None
    if priority == MAP_FIX_PRIORITY_OURS:
        high_tile = tile_A
        low_tile = tile_B
    else:
        high_tile = tile_B
        low_tile = tile_A

    new_tile.append(marker)
    for atom in high_tile:
        if atom[0:5] == "/turf":
            turf_atom = atom
        elif atom[0:5] == "/area":
            area_atom = atom
        else:
            new_tile.append(atom)

    for atom in low_tile:
        if atom[0:5] == "/turf" or atom[0:5] == "/area":
            continue
        else:
            new_tile.append(atom)

    new_tile.append(turf_atom)
    new_tile.append(area_atom)
    return tuple(new_tile)
            

def run_shell_command(command):
    return subprocess.run(command, shell=True, stdout=subprocess.PIPE, universal_newlines=True).stdout
