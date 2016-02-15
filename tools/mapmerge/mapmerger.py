import sys
import os
import pathlib
import ast
import re
import collections
import functools
import time
import traceback

maxx = 0
maxy = 0
key_length = 1

#main("../../_maps/")
def main(map_folder, tgm=0):
    list_of_files = list()
    for root, directories, filenames in os.walk(map_folder):
        for filename in [f for f in filenames if f.endswith(".dmm")]:
        #for filename in filenames:
            list_of_files.append(pathlib.Path(root, filename))

    for i in range(0, len(list_of_files)):
        to_print = "[{}]: {}".format(i, list_of_files[i])
        print(to_print)
        print("".join("-" for _ in range(len(to_print))))

    in_list = input("List the maps you want to merge (example: 1,2,3,4,5):\n")
    in_list = in_list.replace(" ", "")
    in_list = in_list.split(",")

    valid_indices = list()
    for m in in_list:
        index = string_to_num(m)
        if index > 0 and index < len(list_of_files):
            valid_indices.append(index)

    if tgm == "1":
        print("\nMaps will be converted to tgm.")
    else:
        print("\nMaps will not be converted to tgm.")

    print("\nMerging these maps:")
    for i in valid_indices:
        print(list_of_files[i])
    merge = input("\nPress Enter to merge...")
    if merge == "abort":
        print("\nAborted map merge.")
        sys.exit()
    else:
        for i in valid_indices:
            try:
                if merge_map(str(list_of_files[i]), str(list_of_files[i]) + ".backup") != 1:
                    print("ERROR MERGING: {}".format(list_of_files[i]))
                if tgm == "1":
                    try:
                        if os.system("..\dmm2tgm\dmm2tgm.exe \"{}\"".format(str(list_of_files[i]))) != 0:
                            print("Conversion to tgm failed. ({})".format(str(list_of_files[i])))
                    except:
                        print("ERROR: call to dmm2tgm.exe failed. ({})".format(str(list_of_files[i])))
            except FileNotFoundError:
                print("\nERROR: File not found! Make sure you run 'Prepare Maps.bat' before merging.")
                print(str(list_of_files[i]) + " || " + str(list_of_files[i])+".backup")
    print("\nFinished merging.")
            

def merge_map(newfile, backupfile): #JUST CLEAN MY SHIT UP
    shitmap = parse_map(newfile)
    shitDict = shitmap["dictionary"] #key to tile data dictionary
    shitGrid = shitmap["grid"] #x,y coords to tiles (keys) dictionary (the map's layout)
        
    originalmap = parse_map(backupfile)
    originalDict = originalmap["dictionary"]
    originalGrid = originalmap["grid"]

    mergeGrid = dict() #final map layout
    new_keys = dict() #mapping new keys to original keys
    obsolete_keys = list() #mapping original keys to a newly generated key
    tempGrid = dict() #saving tiles with newly generated keys for later processing
    temp_keys = dict() #mapping new keys to newly generated keys
    unused_keys = list(originalDict.keys()) #list with all existing keys that aren't being used
    originalDict_size = len(originalDict)

    for y in range(1,maxy):
        for x in range(1,maxx):
            shitKey = shitGrid[x,y]
            
            #if this key was seen before, add it to the pile immediately
            if shitKey in new_keys:
                mergeGrid[x,y] = new_keys[shitKey]
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
                new_keys[shitKey] = originalKey
                unused_keys.remove(originalKey)
            else:
                #search for the new tile data in the original dictionary, if a key is found add it to the pile, else generate a new key
                newKey = search_data(originalDict, shitData)
                if newKey != None:
                    mergeGrid[x,y] = newKey
                    new_keys[shitKey] = newKey
                    unused_keys.remove(newKey)
                else:
                    newKey = generate_new_key(originalDict)
                    tempGrid[x,y] = newKey
                    temp_keys[shitKey] = newKey
                    originalDict[newKey] = shitData

    #Recycle outdated keys with any new tile data, starting from the bottom of the dictionary
    i = 0
    while i < (len(originalDict) - originalDict_size):
        last_key = next(reversed(originalDict))
        recycled_key = last_key
        if len(unused_keys) > 0:
            recycled_key = unused_keys.pop()

        for entry in tempGrid:
            if tempGrid[entry] == last_key:
                mergeGrid[entry] = recycled_key
                
        originalDict[recycled_key] = originalDict[last_key]
        if recycled_key != last_key:
            originalDict.pop(last_key, None)
        else:
            i += 1
    
    write_dictionary(newfile, originalDict)
    write_grid(newfile, mergeGrid)
    return 1

def write_dictionary(filename, dictionary):
    with open(filename, "w") as output:
        for entry in dictionary:
            output.write("\"{}\" = ({})\n".format(entry, ",".join(dictionary[entry])))

def write_grid(filename, grid):
    with open(filename, "a") as output:
        output.write("\n")
        output.write("(1,1,1) = {\"\n")

        for y in range(1, maxy):
            for x in range(1, maxx):
                output.write(grid[x,y])
            output.write("\n")
        output.write("\"}")
        output.write("\n\n")

def search_data(dictionary, data):
    for entry in dictionary:
        if len(dictionary[entry]) == len(data):
            if set(dictionary[entry]) == frozenset(data):
                return entry

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


def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

main(sys.argv[1], sys.argv[2])
