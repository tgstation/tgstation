import sys
import os
import pathlib
import map_helpers

#main("../../_maps/")
def main(map_folder, tgm=0):
    list_of_files = list()
    for root, directories, filenames in os.walk(map_folder):
        for filename in [f for f in filenames if f.endswith(".dmm")]:
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
        if index >= 0 and index < len(list_of_files):
            valid_indices.append(index)

    if tgm == "1":
        print("\nMaps will be converted to tgm.")
        tgm = True
    else:
        print("\nMaps will not be converted to tgm.")
        tgm = False

    print("\nMerging these maps:")
    for i in valid_indices:
        print(list_of_files[i])
    merge = input("\nPress Enter to merge...")
    if merge == "abort":
        print("\nAborted map merge.")
        sys.exit()
    else:
        for i in valid_indices:
            path_str = str(list_of_files[i])
            try:
                if map_helpers.merge_map(path_str, path_str + ".backup", tgm) != 1:
                    print("ERROR MERGING: {}".format(list_of_files[i]))
                    continue
                print("MERGED: {}".format(path_str))
            except FileNotFoundError:
                print("\nERROR: File not found! Make sure you run 'Prepare Maps.bat' before merging.")
                print(path_str + " || " + path_str+".backup")

    print("\nFinished merging.")

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

main(sys.argv[1], sys.argv[2])
