import argparse
import glob
import traceback

import dmm

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def process_dmm(map_filename):
    problems = []

    with open(map_filename, "r") as file:
        try:
            map_data = dmm.parse_dmm(file)
        except dmm.DMMError as dmm_error:
            problems.append(red(f"Error parsing map.\n  {dmm_error}"))

    return problems

def main(args):
    any_failed = False

    for map_filename in (args.maps or glob.glob("_maps/**/*.dmm", recursive = True)):
        print(map_filename, end = " ")

        success = True
        message = []

        try:
            problems = process_dmm(map_filename)
            if len(problems) > 0:
                success = False
                message += problems
        except KeyboardInterrupt:
            raise
        except Exception:
            success = False

            message.append(f"{red('An exception occurred, this is either a bug in maplint or a bug in a lint.')}\n{traceback.format_exc()}")

        if success:
            print(green("OK"))
        else:
            print(red("X"))
            any_failed = True

        for line in message:
            print(f"- {line}")

    if any_failed:
        exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog = "maplint",
        description = "Checks for common errors in maps.",
    )

    parser.add_argument("maps", nargs = "*")

    args = parser.parse_args()

    main(args)
