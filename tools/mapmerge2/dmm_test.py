import os
import sys
from .dmm import *

def _test_file(fullpath):
    try:
        DMM.from_file(fullpath)
    except Exception:
        print('Failed on:', fullpath)
        raise

def _get_all_dmm_files():
    for dirpath, dirnames, filenames in os.walk('.'):
        if '.git' in dirnames:
            dirnames.remove('.git')
        for filename in filenames:
            if filename.endswith('.dmm'):
                yield os.path.join(dirpath, filename)

def _run_test(file_paths=None):
    count = 0

    if not file_paths:
        file_paths = _get_all_dmm_files()

    for fullpath in file_paths:
        if not os.path.isfile(fullpath):
            continue

        _test_file(fullpath)
        count += 1

    print(f"{os.path.relpath(__file__)}: successfully parsed {count} .dmm files")

def _usage():
    print(f"Usage:")
    print(f"    tools{os.sep}bootstrap{os.sep}python -m {__spec__.name}")
    exit(1)

def _main():
    args = sys.argv[1:]
    if '-help' in args:
        _usage()
        return

    _run_test(args)

if __name__ == '__main__':
    _main()
