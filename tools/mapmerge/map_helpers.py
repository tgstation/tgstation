import collections

maxx = 0
maxy = 0
key_length = 1

def merge_map(newfile, backupfile):
    global key_length
    global maxx
    global maxy
    key_length = 1
    maxx = 1
    maxy = 1

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

    for y in range(1,maxy):
        for x in range(1,maxx):
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
            if set(shitData) == frozenset(originalData):
                mergeGrid[x,y] = originalKey
                known_keys[shitKey] = originalKey
                unused_keys.remove(originalKey)
            else:
                #search for the new tile data in the original dictionary, if a key is found add it to the pile, else generate a new key
                newKey = search_data(originalDict, shitData)
                if newKey != None:
                    mergeGrid[x,y] = newKey
                    known_keys[shitKey] = newKey
                    unused_keys.remove(newKey)
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
            i = 0
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

    write_dictionary(newfile, originalDict)
    write_grid(newfile, mergeGrid)
    return 1

def write_dictionary(filename, dictionary):
    with open(filename, "w") as output:
        for key, value in dictionary.items():
            output.write("\"{}\" = ({})\n".format(key, ",".join(value)))

def write_grid(filename, grid):
    with open(filename, "a") as output:
        output.write("\n")
        output.write("(1,1,1) = {\"\n")

        for y in range(1, maxy):
            for x in range(1, maxx):
                try:
                    output.write(grid[x,y])
                except KeyError:
                    print("Key error: ({},{})".format(x,y))
            output.write("\n")
        output.write("\"}")
        output.write("\n")

def search_data(dictionary, data):
    found_data = None
    try:
        found_data = dictionary.values()[list(dictionary.keys()).index(data)]
    except:
        pass
    return found_data

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

def parse_map(map_file): #supports only one z level per file
    with open(map_file, "r") as map_input:
        characters = map_input.read()

        in_dictionary_block = True #the key = data part of the file
        in_key_block = False #"aaa"
        in_data_block = False # (/thing)"
        after_data_block = False
        parenthesis_counter = 0

        in_grid_block = False #the map layout part of the file
        global key_length
        key_length = 1

        curr_x = 0
        curr_y = 0
        global maxx
        global maxy

        dictionary = collections.OrderedDict()
        grid = dict()

        curr_key = ""
        curr_data = ""

        for c in characters:
            if in_dictionary_block:

                if c == "\n" or c == "\t" or c == "\r":
                    continue
                
                if after_data_block:
                    if c == "(":
                        in_dictionary_block = False
                        after_data_block = False
                        curr_key = ""
                        curr_data = ""
                        continue
                if not in_key_block and not in_data_block:
                    if c == "\"":
                        in_key_block = True
                        after_data_block = False
                    elif c == "(":
                        in_data_block = True
                    continue

                if in_key_block:
                    if c == "\"":
                        in_key_block = False
                        continue
                    curr_key = curr_key + c
                    continue

                if in_data_block:
                    if c == ")":
                        if parenthesis_counter == 0:
                            in_data_block = False
                            after_data_block = True
                            dictionary[curr_key] = curr_data.split(",")
                            key_length = len(curr_key)
                            curr_key = ""
                            curr_data = ""
                            continue
                        else:
                            parenthesis_counter -= 1
                    if c == "(":
                        parenthesis_counter += 1
                    curr_data = curr_data + c
                continue

            if not in_grid_block:
                if c == "\"":
                    in_grid_block = True
                    continue
            else:
                if c == "\n":
                    curr_y += 1

                    if curr_x > maxx:
                        maxx = curr_x
                    curr_x = 1
                    continue
                if c == "\"":
                    break

                curr_key = curr_key + c
                if len(curr_key) == key_length:
                    grid[curr_x,curr_y] = curr_key
                    curr_key = ""
                    curr_x += 1
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
