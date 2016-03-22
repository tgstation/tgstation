import collections

maxx = 0
maxy = 0
key_length = 1

def reset_globals():
    global key_length
    global maxx
    global maxy
    key_length = 1
    maxx = 0
    maxy = 0

def merge_map(newfile, backupfile, tgm):
    reset_globals()

    shitmap = parse_map(newfile)
    shitDict = shitmap["dictionary"] #key to tile data dictionary
    shitGrid = shitmap["grid"] #x,y coords to tiles (keys) dictionary (the map's layout)
        
    originalmap = parse_map(backupfile)
    originalDict = originalmap["dictionary"]
    originalGrid = originalmap["grid"]

    mergeGrid = dict() #final map layout
    known_keys = dict() #mapping known keys to original keys
    tempGrid = dict() #saving tiles with newly generated keys for later processing
    temp_keys = dict() #mapping known keys to newly generated keys
    unused_keys = list(originalDict.keys()) #list with all existing keys that aren't being used
    tempDict = collections.OrderedDict() #mapping new keys to new data
    originalDict_size = len(originalDict)

    for y in range(1,maxy+1):
        for x in range(1,maxx+1):
            shitKey = shitGrid[x,y]

            #if this key was seen before, add it to the pile immediately
            if shitKey in known_keys:
                mergeGrid[x,y] = known_keys[shitKey]
                continue
            #if this key was seen before, add it to the pile immediately
            if shitKey in temp_keys:
                tempGrid[x,y] = temp_keys[shitKey]
                continue

            shitData = shitDict[shitKey]
            originalKey = originalGrid[x,y]
            originalData = originalDict[originalKey]

            #if new tile data at x,y is the same as original tile data at x,y, add to the pile
            if shitData == originalData:
                mergeGrid[x,y] = originalKey
                known_keys[shitKey] = originalKey
                unused_keys.remove(originalKey)
            else:
                #search for the new tile data in the original dictionary, if a key is found add it to the pile, else generate a new key
                newKey = search_key(originalDict, shitData)
                if newKey != None:
                    try:
                        unused_keys.remove(newKey)
                    except ValueError: #caused by a duplicate entry
                        print("WARNING: Correcting duplicate dictionary entry. ({})".format(shitKey))
                    mergeGrid[x,y] = newKey
                    known_keys[shitKey] = newKey    
                #if data at original x,y no longer exists we reuse the key immediately
                elif search_key(shitDict, originalData) == None:
                    mergeGrid[x,y] = originalKey
                    originalDict[originalKey] = shitData
                    unused_keys.remove(originalKey)
                    known_keys[shitKey] = originalKey
                else:
                    if len(tempDict) == 0:
                        newKey = generate_new_key(originalDict)
                    else:
                        newKey = generate_new_key(tempDict)
                    if newKey == "OVERFLOW": #if this happens, merging is impossible
                        print("ERROR: Key overflow detected.")
                        return 0
                    tempGrid[x,y] = newKey
                    temp_keys[shitKey] = newKey
                    tempDict[newKey] = shitData

    sort = 0
    #find gaps in the dictionary keys sequence and add the missing keys to be recycled
    dict_list = list(originalDict.keys())
    for index in range(0, len(dict_list)):
        if index + 1 == len(dict_list):
            break

        key = dict_list[index]
        next_key = dict_list[index+1]

        difference = key_difference(key, next_key)
        if difference > 1:
            i = 1
            nextnew = key
            while i < difference:
                nextnew = get_next_key(nextnew)
                unused_keys.append(nextnew)
                i += 1
            sort = 1


    #Recycle outdated keys with any new tile data, starting from the bottom of the dictionary
    i = 0
    for key, value in reversed(tempDict.items()):
        recycled_key = key
        if len(unused_keys) > 0:
            recycled_key = unused_keys.pop()

        for coord, gridkey in tempGrid.items():
            if gridkey == None:
                continue
            if gridkey == key:
                mergeGrid[coord] = recycled_key
                tempGrid[coord] = None

        originalDict[recycled_key] = value

    #if gaps in the key sequence were found, sort the dictionary for cleanliness
    if sort == 1:
        sorted_dict = collections.OrderedDict()
        next_key = get_next_key("")
        while len(sorted_dict) < len(originalDict):
            try:
                sorted_dict[next_key] = originalDict[next_key]
            except KeyError:
                pass
            next_key = get_next_key(next_key)
        originalDict = sorted_dict

    if tgm:
        write_dictionary_tgm(newfile, originalDict)
        write_grid_coord_small(newfile, mergeGrid)
    else:
        write_dictionary(newfile, originalDict)
        write_grid(newfile, mergeGrid)
    return 1

#write dictionary in tgm format
def write_dictionary_tgm(filename, dictionary): 
    with open(filename, "w") as output:
        output.write("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE \n")
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

#thanks to YotaXP for finding out about this one
def write_grid_coord_small(filename, grid):
    with open(filename, "a") as output:
        output.write("\n")

        for x in range(1, maxx+1):
            output.write("({},{},1) = {{\"\n".format(x, 1, 1))
            for y in range(1, maxy):
                output.write("{}\n".format(grid[x,y]))
            output.write("{}\n\"}}\n".format(grid[x,maxy-1]))

def search_key(dictionary, data):
    for key, value in dictionary.items():
        if value == data:
            return key
    return None

def generate_new_key(dictionary):
    last_key = next(reversed(dictionary))
    return get_next_key(last_key)

def get_next_key(key):
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

        global key_length
        global maxx
        global maxy
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

#subtract keyB from keyA
def key_difference(keyA, keyB):
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

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

#writes a tile data dictionary the same way Dreammaker does
def write_dictionary(filename, dictionary):
    with open(filename, "w") as output:
        for key, value in dictionary.items():
            output.write("\"{}\" = ({})\n".format(key, ",".join(value)))

#writes a map grid the same way Dreammaker does
def write_grid(filename, grid):
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

#inflated map grid; unused
def write_grid_coord(filename, grid):
    with open(filename, "a") as output:
        output.write("\n")
        for y in range(1, maxy+1):
            for x in range(1, maxx+1):
                output.write("({},{},1) = {{\"{}\"}}\n".format(x, y, grid[x,y]))

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
