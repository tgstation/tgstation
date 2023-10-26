import sys
import re
import os.path as path

# Usage: tools/bootstrap/python -m dm_annotator [filename]
# If filename is not provided, stdin is checked instead

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def yellow(text):
    return "\033[33m" + str(text) + "\033[0m"

def annotate(raw_output):
    # Remove ANSI escape codes
    raw_output = re.sub(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]', '', raw_output)

    print("::group::DreamChecker Output")
    print(raw_output)
    print("::endgroup::")

    annotation_regex = r'(?P<filename>.*?), line (?P<line>\d+), column (?P<column>\d+):\s{1,2}(?P<type>error|warning): (?P<message>.*)'
    has_issues = False

    print("DM Code Annotations:")
    for annotation in re.finditer(annotation_regex, raw_output):
        print(f"::{annotation['type']} file={annotation['filename']},line={annotation['line']},col={annotation['column']}::{annotation['message']}")
        has_issues = True

    if not has_issues:
        print(green("No DM issues found"))

def main():
    if len(sys.argv) > 1:
        if not path.exists(sys.argv[1]):
            print(red(f"Error: Annotations file '{sys.argv[1]}' does not exist"))
            sys.exit(1)
        with open(sys.argv[1], 'r') as f:
            annotate(f.read())
    elif not sys.stdin.isatty():
        annotate(sys.stdin.read())
    else:
        print(red("Error: No input provided"))
        print("Usage: tools/bootstrap/python -m dm_annotator [filename]")
        sys.exit(1)

if __name__ == '__main__':
    main()
