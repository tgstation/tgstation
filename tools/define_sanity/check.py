import fnmatch
import glob
import os
import re
import sys

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

def post_error(define_name, file, github_error_style):
    if github_error_style:
        print(f"::error file={file},title=Define Sanity::{define_name} is defined locally in {file} but not undefined locally!")
    else:
        print(red(f"- Error parsing {file}: {define_name} is defined locally in {file} but not undefined locally!"))

parent_directory = "code/**/*.dm"
# This files/directories are expected to have "global" defines, so they must be exempt from this check.
excluded_files = [
    #  Wildcard directories, all files are expected to be exempt.
    "code/__DEFINES/*.dm",
    "code/__HELPERS/*.dm",
    "code/_globalvars/*.dm",
    # Singular files.
    "code/__byond_version_compat.dm",
    "code/_compile_options.dm",
    # TGS files come from another repository so lets not touch them.
    "code/modules/tgs/v3210/commands.dm",
    "code/modules/tgs/v4/api.dm",
    "code/modules/tgs/v5/_defines.dm",
    "code/modules/tgs/core/_definitions.dm",
    "code/modules/unit_tests/_unit_tests.dm",
    # In an ideal world, anything below this line shouldn't be the way it is and moved to the __DEFINES directory. This is not an ideal world.
    # If you disagree, feel free to either refactor them out of this list or move them to the "Singular Files" section.
    "code/controllers/subsystem/atoms.dm",
    "code/controllers/configuration/config_entry.dm",
    "code/modules/client/preferences/_preference.dm",
    "code/datums/keybinding/_defines.dm",
    "code/modules/atmospherics/machinery/components/fusion/hfr_defines.dm",
    "code/datums/keybinding/_defines.dm",
    "code/game/machinery/computer/atmos_computers/__identifiers.dm",
    "code/modules/mafia/_defines.dm",
]

define_regex = re.compile("#define\s?([A-Z0-9_]+)\(?(.+)\)?\s")

filtered_files = []

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

if not on_github:
    print(blue(f"Running define sanity check outside of Github Actions.\nFor assistance, a 'define_sanity_output.txt' file will be generated at the root of your directory if any errors are detected."))

for code_file in glob.glob(parent_directory, recursive=True):
    in_exempt_directory = False
    for exempt_directory in excluded_files:
        if fnmatch.fnmatch(code_file, exempt_directory):
            in_exempt_directory = True
            break
    if not in_exempt_directory:
        filtered_files.append(code_file)

error_found = False

located_error_tuples = []

for applicable_file in filtered_files:
    with open(applicable_file, encoding="utf8") as file:
        file_contents = file.read()
        for define in define_regex.finditer(file_contents):
            define_name = define.group(1)
            if not re.search("#undef\s" + define_name, file_contents):
                located_error_tuples.append((define_name, applicable_file))
                error_found = True

if error_found:

    if on_github:
        for error in located_error_tuples:
            post_error(error[0], error[1], True)
    else:
        with open("define_sanity_output.txt", "w") as output_file:
            for error in located_error_tuples:
                post_error(error[0], error[1], False)
                output_file.write(f"{error[0]} is defined locally in {error[1]} but not undefined locally!\n")

    print(red(f"Please #undef the above defines or remake them as global defines in the code/__DEFINES directory."))
    sys.exit(1)
else:
    print(green("No unhandled local defines found."))
