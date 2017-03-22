import map_helpers
import sys
import os
import time

def main(relative_root):
    git_version = map_helpers.run_shell_command("git version")
    if not git_version:
        print("ERROR: Failed to run git. Make sure it is installed and in your PATH.")
        return False

    print("--- DISCLAIMER ---")
    print("This script is in a testing phase. Verify all the results yourself to make sure you got what you expected. Make sure to read the readme to learn how to use this.")
    input("Press Enter to GO\n")
    
    file_conflicts = map_helpers.run_shell_command("git diff --name-only --diff-filter=U").split("\n")
    map_conflicts = [path for path in file_conflicts if path[len(path)-3::] == "dmm"]

    for i in range(0, len(map_conflicts)):
        print("[{}]: {}".format(i, map_conflicts[i]))
    selection = input("Choose maps you want to fix (example: 1,3-5,12):\n")
    selection = selection.replace(" ", "")
    selection = selection.split(",")

    #shamelessly copied from mapmerger cli
    valid_indices = list()
    for m in selection:
        index_range = m.split("-")
        if len(index_range) == 1:
            index = map_helpers.string_to_num(index_range[0])
            if index >= 0 and index < len(map_conflicts):
                valid_indices.append(index)
        elif len(index_range) == 2:
            index0 = map_helpers.string_to_num(index_range[0])
            index1 = map_helpers.string_to_num(index_range[1])
            if index0 >= 0 and index0 <= index1 and index1 < len(map_conflicts):
                valid_indices.extend(range(index0, index1 + 1))

    if not len(valid_indices):
        print("No map selected, exiting.")
        sys.exit()

    print("Attempting to fix the following maps:")
    for i in valid_indices:
        print(map_conflicts[i])


    marker = None
    priority = 0
    print("\nFixing modes:")
    print("[{}]: Dictionary conflict fixing mode".format(map_helpers.MAP_FIX_DICTIONARY))
    print("[{}]: Full map conflict fixing mode".format(map_helpers.MAP_FIX_FULL))
    mode = map_helpers.string_to_num(input("Select fixing mode [Dictionary]: "))
    if mode != map_helpers.MAP_FIX_FULL:
        mode = map_helpers.MAP_FIX_DICTIONARY
        print("DICTIONARY mode selected.")
    else:
        marker = input("FULL mode selected. Input a marker [/obj/effect/debugging/marker]: ")
        if not marker:
            marker = "/obj/effect/debugging/marker"
        print("Marker selected: {}".format(marker))

        print("\nVersion priorities:")
        print("[{}]: Your version".format(map_helpers.MAP_FIX_PRIORITY_OURS))
        print("[{}]: Their version".format(map_helpers.MAP_FIX_PRIORITY_THEIRS))
        priority = map_helpers.string_to_num(input("Select priority [Yours]: "))
        if priority != map_helpers.MAP_FIX_PRIORITY_THEIRS:
            priority = map_helpers.MAP_FIX_PRIORITY_OURS
            print("Your version will be prioritized.")
        else:
            print("Their version will be prioritized.")

    ed = "FIXED" if mode == map_helpers.MAP_FIX_DICTIONARY else "MARKED"
    ing = "FIXING" if mode == map_helpers.MAP_FIX_DICTIONARY else "MARKING"

    print("\nMaps will be converted to TGM.")
    print("Writing maps to 'file_path/file_name.fixed.dmm'. Please verify the results before commiting.")
    if mode == map_helpers.MAP_FIX_FULL:
        print("After editing the marked maps, run them through the map merger!")
    input("Press Enter to start.")
    
    print(".")
    time.sleep(0.3)
    print(".")
    
    for i in valid_indices:
        path = map_conflicts[i]
        print("{}: {}".format(ing, path))
        ours_map_raw_text = map_helpers.run_shell_command("git show HEAD:{}".format(path))
        theirs_map_raw_text = map_helpers.run_shell_command("git show MERGE_HEAD:{}".format(path))

        common_ancestor_hash = map_helpers.run_shell_command("git merge-base HEAD MERGE_HEAD").strip()
        base_map_raw_text = map_helpers.run_shell_command("git show {}:{}".format(common_ancestor_hash, path))

        ours_map = map_helpers.parse_map(ours_map_raw_text)
        theirs_map = map_helpers.parse_map(theirs_map_raw_text)
        base_map = map_helpers.parse_map(base_map_raw_text)

        if map_helpers.fix_map_git_conflicts(base_map, ours_map, theirs_map, mode, marker, priority, relative_root+path):
            print("{}: {}".format(ed, path))
        print(".")

main(sys.argv[1])
