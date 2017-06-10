import map_helpers
import sys
import shutil

#main("../../_maps/")
def main(map_folder, tgm=0):
    maps = map_helpers.prompt_maps(map_folder, "merge", tgm)

    print("\nMerging these maps:")
    for i in maps.indices:
        print(str(maps.files[i])[len(map_folder):])

    merge = input("\nPress Enter to merge...\n")
    if merge == "abort":
        print("\nAborted map merge.")
        sys.exit()
    else:
        for i in maps.indices:
            path_str = str(maps.files[i])
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
