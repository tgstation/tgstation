import os

headers = """// DM Environment file for tgstation.dme.
// All manual changes should be made outside the BEGIN_ and END_ blocks.
// New source code should be placed in .dm files: choose File/New --> Code File.
// BEGIN_INTERNALS
// END_INTERNALS

// BEGIN_FILE_DIR
#define FILE_DIR .
// END_FILE_DIR

// BEGIN_PREFERENCES
#define DEBUG
// END_PREFERENCES

// BEGIN_INCLUDE
"""

# What DME you want to generate
TARGET_DME = 'tgstation.dme'

# Things we dont want
ignored_dirs = [
    'tgs',          # Has its own includes
    R".\tools",     # We dont include tools
    "_maps",        # We dont include maps
    "unit_tests"    # Has its own includes
]

# Things we want but are excluded
snowflakes = [
    "includes.dm",      # Special Includes Folder
    "_basemap.dm",      # Dont Ask Me
    "_unit_tests.dm"    # Special Includes
]

# Files we don't care about
ignored_files = [
    "_readme.dm",           # It's a readme
    "unused.dm",            # Unused
    "nanite_hijacker.dm",   # Wasnt imported
    "xenobio.dm"            # Wasnt imported
]
"""
Shamelessly Stolen from https://kubanaltan.wordpress.com/2011/01/21/os-walk-alphabetically-directory-recursion/

TLDR: Sorts by a A b B c C, probably anyways
"""
def sortedWalk(top, topdown=True, onerror=None):
    from os.path import join, isdir, islink

    names = os.listdir(top)
    names.sort(key=len)
    dirs, nondirs = [], []

    for name in names:
        if isdir(os.path.join(top, name)):
            dirs.append(name)
        else:
            nondirs.append(name)

    if topdown:
        yield top, dirs, nondirs
    for name in dirs:
        path = join(top, name)
        if not os.path.islink(path):
            for x in sortedWalk(path, topdown, onerror):
                yield x
    if not topdown:
        yield top, dirs, nondirs

print(f'Generating {TARGET_DME}')
with open(TARGET_DME, 'w') as enviroment:
    enviroment.truncate(0)
    enviroment.write(headers) # No DME is complete without headers
    for root, dirs, files in sortedWalk('.'):
        files.sort(key=str.lower)
        dirs.sort(key=str.lower)
        for file in files:
            if(file.endswith(('.dm', '.dmf'))):
                ignoring = False # Can't compare in list have to do this sadly
                #include "code\__DEFINES\_tick.dm"
                for ignored_dir in ignored_dirs:
                    if ignored_dir in root:
                        if file in snowflakes:
                            enviroment.write(f'#include "{root[2:]}\\{file}"\n')
                        ignoring = True
                        break
                if(ignoring):
                    continue
                if file in ignored_files:
                    continue
                enviroment.write(f'#include "{root[2:]}\\{file}"\n')
    enviroment.write(f'// END_INCLUDE\n')
    print(f'Finished generating {TARGET_DME}')
