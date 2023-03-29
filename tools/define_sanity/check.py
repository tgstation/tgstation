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
        print(red(f"- Failure: {define_name} is defined locally in {file} but not undefined locally!"))

parent_directory = "code/**/*.dm"

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

# This files/directories are expected to have "global" defines, so they must be exempt from this check.
# Add directories as string here to automatically be exempt in case you have a non-complaint file name.
excluded_files = [
    #  Wildcard directories, all files are expected to be exempt.
    "code/__DEFINES/*.dm",
    "code/__HELPERS/*.dm",
    "code/_globalvars/*.dm",
    # TGS files come from another repository so lets not worry about them.
    "code/modules/tgs/**/*.dm",
]

# In addition to the previous directories, any file pre-pended with a `_` is automatically exempt.
# What does this mean? Basically let's say you have a file named `code/modules/whatever/_example.dm`.
# We scan every file name for that pre-pended `_` in "_example" and if it exists, we don't scan it for defines.

define_regex = re.compile(r"#define\s?([A-Z0-9_]+)\(?(.+)\)?\s")
file_determination_regex = ""

if on_github or os.name == "posix":
    re.compile(r"code(.+)?\/(.+).dm") # i hate it here
else:
    re.compile(r"code(.+)?\\(.+).dm")

output_file_name = "define_sanity_output.txt"
how_to_fix_message = "Please #undef the above defines or remake them as global defines in the code/__DEFINES directory."

filtered_files = []

if not on_github:
    print(blue(f"Running define sanity check outside of Github Actions.\nFor assistance, a '{output_file_name}' file will be generated at the root of your directory if any errors are detected."))

for code_file in glob.glob(parent_directory, recursive=True):
    exempt_file = False
    for exempt_directory in excluded_files:
        if fnmatch.fnmatch(code_file, exempt_directory):
            exempt_file = True
            break

    if exempt_file:
        continue

    file_regex_result = re.search(file_determination_regex, code_file)

    refined_file_name = file_regex_result.group(2)
    if refined_file_name[0] == "_":
        exempt_file = True

    if not exempt_file:
        filtered_files.append(code_file)

located_error_tuples = []

for applicable_file in filtered_files:
    with open(applicable_file, encoding="utf8") as file:
        file_contents = file.read()
        for define in define_regex.finditer(file_contents):
            define_name = define.group(1)
            if not re.search("#undef\s" + define_name, file_contents):
                located_error_tuples.append((define_name, applicable_file))
                error_found = True

if len(located_error_tuples):

    string_list = []
    for error in located_error_tuples:
        if not on_github:
            post_error(error[0], error[1], False)
            string_list.append(f"{error[0]} is defined locally in {error[1]} but not undefined locally!")
        else:
            post_error(error[0], error[1], True)

    if len(string_list):
        with open(output_file_name, "w") as output_file:
            output_file.write("\n".join(string_list))
            output_file.write("\n\n" + how_to_fix_message)

    print(red(how_to_fix_message))
    sys.exit(1)
else:
    print(green("No unhandled local defines found."))
