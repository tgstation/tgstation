import map_helpers
import sys
import shutil

#main("../../_maps/")
def main(map_folder):
    tgm = "1"
    maps = map_helpers.prompt_maps(map_folder, "convert", tgm)

    print("\nConverting these maps:")
    for i in maps.indices:
        print(str(maps.files[i])[len(map_folder):])

    convert = input("\nPress Enter to convert...\n")
    if convert == "abort":
        print("\nAborted map convert.")
        sys.exit()
    else:
        for i in maps.indices:
            path_str = str(maps.files[i])
            path_str_pretty = path_str[len(map_folder):]
            error = map_helpers.merge_map(path_str, path_str, tgm)
            if error > 1:
                print(map_helpers.error[error])
                continue
            if error == 1:
                print(map_helpers.error[1])
            print("CONVERTED: {}".format(path_str_pretty))
            print("  -  ")

    print("\nFinished converting.")

def string_to_num(s):
    try:
        return int(s)
    except ValueError:
        return -1

main(sys.argv[1])
