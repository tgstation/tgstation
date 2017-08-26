import argparse

parser = argparse.ArgumentParser(description='Merge two DME files together')
parser.add_argument('upstream_dme')
parser.add_argument('downstream_dme')
parser.add_argument('module_folder')

args = parser.parse_args()

search_tag_begin = "// BEGIN_INCLUDE"
search_tag_end = "// END_INCLUDE"
include_tag = "#include "

def parse_dme(f):
    should_parse = False
    files = []
    with open(f) as file:
        for line in file:
            line = line.strip()
            if line == search_tag_begin:
                should_parse = True
                continue

            if line == search_tag_end:
                should_parse = False
                continue

            if should_parse and line.startswith(include_tag):
                included_file = line.replace('"', '').replace(include_tag, '')
                files.append(included_file)
    return files



upstream_files = parse_dme(args.upstream_dme)
downstream_files = parse_dme(args.downstream_dme)

print("upstream currently includes {} files".format(len(upstream_files)))
print("downstream currently includes {} files".format(len(downstream_files)))