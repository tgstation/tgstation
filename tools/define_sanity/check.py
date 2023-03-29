import fnmatch
import glob
import sys
import re

parent_directory = "code/**/*.dm"
# This files/directories are expected to have "global" defines, so they must be exempt from this check.
excluded_files = [
    #  Wildcard directories, all files are expected to be exempt.
    "code/__DEFINES/*.dm",
    "code/__HELPERS/*.dm",
    "code/_globalvars/*.dm",
    # Singular files, which are also exempt.
    "code/__byond_version_compat.dm",
    "code/_compile_options.dm",
    "code/modules/tgs/v3210/commands.dm",
    "code/modules/tgs/v4/api.dm",
    "code/modules/tgs/v5/_defines.dm",
    "code/modules/unit_tests/_unit_tests.dm",
    # In an ideal world, anything below this line shouldn't be the way it is and moved to the __DEFINES directory. This is not an ideal world.
    "code/controllers/subsystem/atoms.dm",
    "code/controllers/configuration/config_entry.dm",
    "code/datums/keybinding/_defines.dm",
    "code/modules/atmospherics/machinery/components/fusion/hfr_defines.dm",
    "code/datums/keybinding/_defines.dm",
    "code/game/machinery/computer/atmos_computers/__identifiers.dm",
    "code/modules/mafia/_defines.dm",
]

define_regex = re.compile("#define\s([A-Z0-9_]+)\s")

filtered_files = []

for code_file in glob.glob(parent_directory, recursive=True):
    in_exempt_directory = False
    for exempt_directory in excluded_files:
        if fnmatch.fnmatch(code_file, exempt_directory):
            in_exempt_directory = True
            break

    if not in_exempt_directory:
        filtered_files.append(code_file)

error_found = False

strings_to_output = [] #remove me

for applicable_file in filtered_files:
    add_file_to_list = False
    with open(applicable_file, encoding="utf8") as file:
        file_contents = file.read()
        for define in define_regex.finditer(file_contents):
            define_name = define.group(1)
            if not re.search("#undef\s" + define_name, file_contents):
                string = f"{define_name} is defined in {applicable_file} but not undefined!" #remove me
                string.replace("\\", "/") #remove me
                strings_to_output.append(string + "\n") #remove me
                print(string)
                error_found = True

if error_found:
    print(f"Please #undef the above defines or remake them as global defines in the /__DEFINES directory.")
    with open('output.txt', 'w') as f: #remove me
        for string in strings_to_output:
            f.write(string)
    sys.exit(1)
