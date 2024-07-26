import sys
import re

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def annotate(raw_output):
    # Remove ANSI escape codes
    raw_output = re.sub(r'(\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]', '', raw_output)

    print("::group::OpenDream Output")
    print(raw_output)
    print("::endgroup::")

    annotation_regex = r'((?P<type>Error|Warning) (?P<errorcode>OD(?P<errornumber>\d{4})) at (?P<location>(?P<filename>.+):(?P<line>\d+):(?P<column>\d+)|<internal>): (?P<message>.+))'
    failures_detected = False
    expected_failure_case_detected = False # this is just here so this script breaks if we forget to set it to True when we expect a failure. remove this when we have handled the expected failure

    print("OpenDream Code Annotations:")
    for annotation in re.finditer(annotation_regex, raw_output):
        message = annotation['message']
        if message == "Unimplemented proc & var warnings are currently suppressed": # this happens every single run, it's important to know about it but we don't need to throw an error
            message += " (This is expected and can be ignored)" # also there's no location for it to annotate to since it's an <internal> failure.
            expected_failure_case_detected = True

        if annotation['type'] == "Error":
            failures_detected = True

        error_string = f"{annotation['errorcode']}: {message}"

        if annotation['location'] == "<internal>":
            print(f"::{annotation['type']} file=,line=,col=::{error_string}")
        else:
            print(f"::{annotation['type']} file={annotation['filename']},line={annotation['line']},col={annotation['column']}::{error_string}")

    if failures_detected:
        sys.exit(1)
        return

    if not expected_failure_case_detected:
        print(red("Failed to detect the expected failure case! If you have recently changed how we work with OpenDream Pragmas, please fix the od_annotator script!"))
        sys.exit(1)
        return

    print(green("No OpenDream issues found!"))

annotate(sys.stdin.read())
