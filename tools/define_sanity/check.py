import fnmatch
import glob
import sys
import re

parent_directory = "code/**/*.dm"
# This two directories are expected to have "global" defines, so they must be exempt from this check.
defines_directory = "code/__DEFINES/*.dm"
helpers_directory = "code/__HELPERS/*.dm"

define_regex = re.compile("#define\s([A-Z0-9_]+)\s")

filtered_files = []

for code_file in glob.glob(parent_directory, recursive=True):
    if not fnmatch.fnmatch(code_file, defines_directory) and not fnmatch.fnmatch(code_file, helpers_directory):
        filtered_files.append(code_file)

error_found = False

for applicable_file in filtered_files:
    add_file_to_list = False
    with open(applicable_file, encoding="utf8") as file:
        file_contents = file.read()
        for define in define_regex.finditer(file_contents):
            define_name = define.group(1)
            if not re.search("#undef\s" + define_name, file_contents):
                print(f"{define_name} is defined in {applicable_file} but not undefined!")
                error_found = True

if error_found:
    print(f"Please #undef the above defines or remake them as global defines in the /__DEFINES directory.")
    sys.exit(1)
