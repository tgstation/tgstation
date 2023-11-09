import fnmatch
import glob
import os
import re
import sys

define_regex = re.compile(r"(\s+)?#define\s?([A-Z0-9_]+)\(?(.+)\)?")

output_file_name = "trait_validity_output.txt"
how_to_fix_message = "Please ensure that all traits in the code/__DEFINES/trait_declarations.dm file are added in the code/_globalvars/traits.dm file."

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def blue(text):
    return "\033[34m" + str(text) + "\033[0m"

# simple way to check if we're running on github actions, or on a local machine
on_github = os.getenv("GITHUB_ACTIONS") == "true"

defines_file = "code/__DEFINES/trait_declarations.dm"
globalvars_file = "code/_globalvars/traits.dm"

def post_error(define_name):
    if on_github:
        print(f"::error file={defines_file},title=Define Sanity::{define_name} is defined in {defines_file} but not added to {globalvars_file}!")
    else:
        print(red(f"- Failure: {define_name} is defined in {defines_file} but not added to {globalvars_file}!"))

number_of_defines = 0

if not on_github:
    print(blue(f"Running define sanity check outside of Github Actions.\nFor assistance, a '{output_file_name}' file will be generated at the root of your directory if any errors are detected."))

if not os.path.isfile(defines_file):
    print(red(f"Could not find the defines file '{defines_file}'!"))
    sys.exit(1)

if not os.path.isfile(globalvars_file):
    print(red(f"Could not find the globalvars file '{globalvars_file}'!"))
    sys.exit(1)

defines_to_search_for = []
missing_defines = []

with open(defines_file, "r") as file:
    defines_file_contents = file.read()
    for define in define_regex.finditer(defines_file_contents):
        number_of_defines += 1
        defines_to_search_for.append(define.group(2))

if number_of_defines == 0:
    print(red("No defines found! This is likely an error."))
    sys.exit(1)

if number_of_defines <= 450:
    print(red(f"Only found {number_of_defines} defines! Something has likely gone wrong as the number of local defines should not be this low."))
    sys.exit(1)

with open(globalvars_file, "r") as file:
    globalvars_file_contents = file.read()
    for define_name in defines_to_search_for:
        searchable_string = "\"" + define_name + "\" = " + define_name
        if not re.search(searchable_string, globalvars_file_contents):
            missing_defines.append(define_name)

if len(missing_defines):
    string_list = []
    for missing_define in missing_defines:
        if not on_github:
            post_error(missing_define)
            string_list.append(f"{define_name} is defined in {defines_file} but not added to {globalvars_file}!")
        else:
            post_error(missing_define)

    if len(string_list):
        with open(output_file_name, "w") as output_file:
            output_file.write("\n".join(string_list))
            output_file.write("\n\n" + how_to_fix_message)

    print(red(how_to_fix_message))
    sys.exit(1)

else:
    print(green(f"All traits were found in both files! (found {number_of_defines} defines)"))
