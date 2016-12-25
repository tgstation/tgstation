import map_helpers
import sys
import shutil

def main():
    if len(sys.argv) < 2:
        print("usage: mapconvert INFILE [OUTFILE]", file=sys.stderr)
    elif len(sys.argv) == 2:
        shutil.copyfile(sys.argv[1], sys.argv[1] + ".before")
        map_helpers.convert_map(sys.argv[1], sys.argv[1])
    else:
        shutil.copyfile(sys.argv[1], sys.argv[1] + ".before")
        map_helpers.convert_map(sys.argv[1], sys.argv[2])

main()
