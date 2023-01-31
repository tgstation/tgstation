import argparse
import glob
import pathlib
import traceback
import yaml

from . import dmm, lint
from .error import MaplintError

def green(text):
    return "\033[32m" + str(text) + "\033[0m"

def red(text):
    return "\033[31m" + str(text) + "\033[0m"

def process_dmm(map_filename, lints):
    problems = []

    with open(map_filename, "r") as file:
        try:
            map_data = dmm.parse_dmm(file)
        except MaplintError as error:
            problems.append(red(f"Error parsing map.\n  {error}") + traceback.format_exc())

        for lint_name, lint in lints.items():
            try:
                for result in lint.run(map_data):
                    tail = f"\n  {lint.help}" if lint.help is not None else ""
                    problems.append(f"{red(lint_name)}: {result}{tail}")
            except KeyboardInterrupt:
                raise
            except Exception:
                problems.append(f"{red('An exception occurred, this is either a bug in maplint or a bug in a lint.')}\n{traceback.format_exc()}")

    return problems

def main(args):
    any_failed = False

    lints = {}

    lint_base = pathlib.Path(__file__).parent.parent / "lints"
    lint_filenames = []
    if args.lints is None:
        lint_filenames = lint_base.glob("*.yml")
    else:
        lint_filenames = [lint_base / f"{lint_name}.yml" for lint_name in args.lints]

    for lint_filename in lint_filenames:
        try:
            lints[lint_filename.stem] = lint.Lint(yaml.safe_load(lint_filename.read_text()))
        except MaplintError as error:
            print(red(f"Error loading {lint_filename.stem}.\n  ") + str(error))
            any_failed = True
        except Exception:
            print(red(f"Error loading {lint_filename.stem}."))
            traceback.print_exc()
            any_failed = True

    for map_filename in (args.maps or glob.glob("_maps/**/*.dmm", recursive = True)):
        print(map_filename, end = " ")

        success = True
        message = []

        try:
            problems = process_dmm(map_filename, lints)
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
    parser.add_argument("--lints", nargs = "*")

    args = parser.parse_args()

    main(args)
