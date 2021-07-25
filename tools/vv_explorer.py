import argparse
import pathlib
import re
import logging
import json
from pprint import pprint

Typepath = str
Variable = str

def make_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("dme_file", help="tgstation.dme file", type=pathlib.Path)
    parser.add_argument("-o", "--output", type=pathlib.Path, default="vv_explorer.json")
    return parser

MANUAL_PARENT_TYPES = {
    "/area": "/atom",
    "/turf": "/atom",
    "/obj": "/atom/movable",
    "/mob": "/atom/movable",
    "/atom": "/datum",
    "/client": "/datum",
}


TYPE_DEFINITION_REGEX = re.compile(r"^(?P<typepath>(/[^/()*]+)+)$")
PROC_DEFINITION_REGEX = re.compile(r"^(/[^/()*]+)+\(")
VAR_DEFINITION_REGEX = re.compile(r"^(\t| +)var/([^/= ]+/)*(?P<varname>[^/= ]+)")


def parse_dm_text(dm_text: str) -> dict[Typepath, list[Variable]]:
    typepaths = {}
    current_type = None
    for line in dm_text.split("\n"):
        # Type definition
        if match := TYPE_DEFINITION_REGEX.match(line):
            current_type = match.group("typepath")
            logging.debug(f"Found type definition for {current_type}")
        # Proc definition
        elif PROC_DEFINITION_REGEX.match(line):
            current_type = None
        # Variable definition inside type def
        elif current_type and (match := VAR_DEFINITION_REGEX.match(line)):
            variable_name = match.group("varname")
            try:
                typepaths[current_type].append(variable_name)
            except KeyError:
                typepaths[current_type] = [variable_name]

            typepaths[current_type].sort()
    return typepaths


def parse_dme(dme_text: str, basepath: pathlib.Path) -> list[pathlib.Path]:
    paths = []
    for line in dme_text.split("\n"):
        if match := re.match('#include "([^"]+)"', line):
            combined = basepath / pathlib.PureWindowsPath(match.group(1))
            paths.append(combined)

    return paths


def get_parent_tree(typepath: Typepath) -> list[Typepath]:
    tree = [typepath]
    while True:
        if typepath in MANUAL_PARENT_TYPES:
            typepath = MANUAL_PARENT_TYPES[typepath]
        else:
            parts = typepath.split("/")
            typepath = "/".join(parts[:-1])

        if not typepath:
            break

        tree.append(typepath)
    return tree

def generate_annotated_type_tree(
    typepaths: dict[Typepath, list[Variable]]
) -> dict[Typepath, dict[Variable, list[Typepath]]]:
    type_tree = {}

    for typepath, variables in typepaths.items():
        type_tree[typepath] = {}

        parent_tree = get_parent_tree(typepath)
        for parent_typepath in parent_tree:
            type_tree[typepath][parent_typepath] = typepaths.get(parent_typepath, [])

    return type_tree

if __name__ == "__main__":

    args = make_parser().parse_args()
    dm_files = []
    with open(args.dme_file) as f:
        dm_files = parse_dme(f.read(), args.dme_file.parent)

    all_typepaths = {}

    for dm_file in dm_files:
        with open(dm_file) as f:
            dm_text = f.read()
        additional_typepaths = parse_dm_text(dm_text)
        for typepath, variable_list in additional_typepaths.items():
            try:
                all_typepaths[typepath].extend(variable_list)
            except:
                all_typepaths[typepath] = list(variable_list)

    #annotated_tree = generate_annotated_type_tree(all_typepaths)
    with open(args.output, "w") as f:
        #json.dump(annotated_tree, f, indent=2)
        json.dump(all_typepaths, f, indent=2)
