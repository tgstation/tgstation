import sys

try:
    version = sys.version_info
    if version.major < 3 or (version.major == 3 and version.minor < 5):
        print("ERROR: You are running an incompatible version of Python. The current minimum version required is [3.5].\nYour version: {}".format(sys.version))
        sys.exit()
except:
    print("ERROR: Something went wrong, you might be running an incompatible version of Python. The current minimum version required is [3.5].\nYour version: {}".format(sys.version))
    sys.exit()

import collections
import hashlib

# string -> int
def tgm_hash(string):
    i = int(hashlib.md5(string.encode("utf-8")).hexdigest(), 16)
    return i % (52 ** 3)

# int -> 3 char string
def hash_to_key(h):
    d1 = h % 52
    d2 = (h // 52) % 52
    d3 = (h // (52 * 52)) % 52
    def d2c(i):
            return chr(ord('a' if i < 26 else'A') + (i % 26))
    return d2c(d3) + d2c(d2) + d2c(d1)

def convert_map(infile, outfile):
    parsed_map = parse_map(infile)
    maxx = parsed_map["maxx"]
    maxy = parsed_map["maxy"]
    dictionary_in = parsed_map["dictionary"]
    grid_in = parsed_map["grid"]

    with open(outfile, "w") as output:
        for y in range(1,maxy+1):
            for x in range(1,maxx+1):
                key = hash_to_key((x-1) + (y-1)*maxx)
                output.write("\"{}\"=(\n".format(key))
                output.write(parsed_value_to_string(dictionary_in[grid_in[x,y]]))
                output.write(")\n")
                output.write('({},{},1)={{"{}"}}\n'.format(x, y, key))

def parsed_value_to_string(list_):
    string = ""
    for thing in list_:
        in_quote_block = False
        in_varedit_block = False
        for char in thing:
            if in_quote_block:
                if char == '"':
                    in_quote_block = False
                string = string + char
                continue
            elif char == '"':
                in_quote_block = True
                string = string + char
                continue

            if not in_varedit_block:
                if char == "{":
                    in_varedit_block = True
                    string = string + "{\n"
                    continue
            else:
                if char == ";":
                    string = string + ";\n"
                    continue
                elif char == "}":
                    string = string + "\n}"
                    in_varedit_block = False
                    continue

            string = string + char
                
        if list_.index(thing) != len(list_) - 1:
            string = string + ",\n"

    return string

def write_dictionary_tgm(filename, dictionary): 
    with open(filename, "w") as output:
        for key in sorted(dictionary.keys()):
            output.write("\"{}\" = (".format(key))
            output.write(parsed_value_to_string(dictionary[key]))
            output.write(")\n")

def write_grid_coord_small(filename, grid, maxx, maxy):
    with open(filename, "a") as output:
        output.write("\n")

        for x in range(1, maxx+1):
            output.write("({},{},1) = {{\"\n".format(x, 1, 1))
            for y in range(1, maxy):
                output.write("{}\n".format(grid[x,y]))
            output.write("{}\n\"}}\n".format(grid[x,maxy]))

#still does not support more than one z level per file, but should parse any format
def parse_map(map_file):
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
        
        maxx = 0
        maxy = 0
        key_length_local = 0
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
                        key_length_local = len(curr_key)
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
                    if len(curr_key) == key_length_local:
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
        data["key_length"] = key_length_local
        data["maxx"] = maxx
        data["maxy"] = maxy
        return data

