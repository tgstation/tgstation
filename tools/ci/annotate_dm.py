import sys
import re
import os.path as path

# Usage: python3 annotate_dm.py [filename]
# If filename is not provided, stdin is checked instead

raw_output = ""

if len(sys.argv) > 1:
    if not path.exists(sys.argv[1]):
        print(f"Annotations file '{sys.argv[1]}' does not exist")
        sys.exit(1)
    with open(sys.argv[1], 'r') as f:
        raw_output = f.read()
elif not sys.stdin.isatty():
    raw_output = sys.stdin.read()

# Remove ANSI escape codes
raw_output = re.sub(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]', '', raw_output)

annotation_regex = r'(?P<filename>.*?), line (?P<line>\d+), column (?P<column>\d+):\s{1,2}(?P<type>error|warning): (?P<message>.*)'

has_issues = False

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def yellow(text):
    return "\033[33m" + str(text) + "\033[0m"

for annotation in re.finditer(annotation_regex, raw_output):
    annotatation_type = annotation['type']

    if(annotation['type'] == "error"):
        annotation_type = red(annotation['type'])
    elif(annotation['type'] == "warning"):
        annotation_type = yellow(annotation['type'])

    print(f"::{annotatation_type} file={annotation['filename']},line={annotation['line']},col={annotation['column']}::{annotation['message']}")
    has_issues = True

if not has_issues:
    print(green("No DM issues found"))
