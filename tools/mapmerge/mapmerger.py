import map_helpers
import sys
import os
import pathlib
import shutil

#main("../../_maps/")
def main(map_folder, tgm=0):
    list_of_files = list()
    for root, directories, filenames in os.walk(map_folder):
        for filename in [f for f in filenames if f.endswith(".dmm")]:
            list_of_files.append(pathlib.Path(root, filename))

    last_dir = ""
    for i in range(0, len(list_of_files)):
        this_dir = list_of_files[i].parent
        if last_dir != this_dir:
            print("--------------------------------")
            last_dir = this_dir
        print("[{}]: {}".format(i, str(list_of_files[i])[len(map_folder):]))

    print("--------------------------------")
    in_list = input("List the maps you want to merge (example: 1,3-5,12):\n")
    in_list = in_list.replace(" ", "")
    in_list = in_list.split(",")

    valid_indices = list()
    for m in in_list:
        index_range = m.split("-")
        if len(index_range) == 1:
            index = string_to_num(index_range[0])
            if index >= 0 and index < len(list_of_files):
                valid_indices.append(index)
        elif len(index_range) == 2:
            index0 = string_to_num(index_range[0])
            index1 = string_to_num(index_range[1])
            if index0 >= 0 and index0 <= index1 and index1 < len(list_of_files):
                valid_indices.extend(range(index0, index1 + 1))

    if tgm == "1":
        print("\nMaps will be converted to tgm.")
        tgm = True
    else:
        print("\nMaps will not be converted to tgm.")
        tgm = False

    print("\nMerging these maps:")
    for i in valid_indices:
        print(str(list_of_files[i])[len(map_folder):])
    merge = input("\nPress Enter to merge...\n")
    if merge == "abort":
        print("\nAborted map merge.")
        sys.exit()
    else:
        for i in valid_indices:
            path_str = str(list_of_files[i])
            shutil.copyfile(path_str, path_str + ".before")
            path_str_pretty = path_str[len(map_folder):]
            try:
                error = map_helpers.merge_map(path_str, path_str + ".backup", tgm)
                if error > 1:
                    print(map_helpers.error[error])
                    os.remove(path_str + ".before")
                    continue
                if error == 1:
                    print(map_helpers.error[1])
                print("MERGED: {}".format(path_str_pretty))
                print("  -  ")
            except FileNotFoundError:
                print("ERROR: File not found! Make sure you run 'Prepare Maps.bat' before merging.")
                print("MISSING BACKUP FILE: " + path_str_pretty + ".backup")
                print("  -  ")

    print("\nFinished merging.")
    print("\nNOTICE: A version of the map files from before merging have been created for debug purposes.\nDo not delete these files until it is sure your map edits have no undesirable changes.")

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

main(sys.argv[1], sys.argv[2])
