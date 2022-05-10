import functools
import sys

reading = False

lines = []

for line in sys.stdin:
    line = line.strip()

    if line == "// BEGIN_INCLUDE":
        reading = True
        continue
    elif line == "// END_INCLUDE":
        break
    elif not reading:
        continue

    lines.append(line)

def compare_lines(a, b):
    # Remove initial include as well as the final quotation mark
    a = a[len("#include \""):-1].lower()
    b = b[len("#include \""):-1].lower()

    a_segments = a.split('\\')
    b_segments = b.split('\\')

    for (a_segment, b_segment) in zip(a_segments, b_segments):
        a_is_file = a_segment.endswith(".dm")
        b_is_file = b_segment.endswith(".dm")

        # code\something.dm will ALWAYS come before code\directory\something.dm
        if a_is_file and not b_is_file:
            return -1

        if b_is_file and not a_is_file:
            return 1

        # interface\something.dm will ALWAYS come after code\something.dm
        if a_segment != b_segment:
            return (a_segment > b_segment) - (a_segment < b_segment)

    raise f"Two lines were exactly the same ({a} vs. {b})"

sorted_lines = sorted(lines, key = functools.cmp_to_key(compare_lines))

for (index, line) in enumerate(lines):
    if sorted_lines[index] != line:
        print(f"The include at line {index + 1} is out of order ({line})")
        print(f"::error file=tgstation.dme,line={index+1},title=DME Validator::The include at line {index + 1} is out of order ({line})")
        sys.exit(1)
