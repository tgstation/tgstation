# I know we already have one in mapmerge, but this one can afford to be significantly simpler to interface with
# by virtue of being read-only.
import re
from dataclasses import dataclass, field
from typing import IO

from .common import Constant, Filename, Null, Typepath
from .error import MapParseError, MaplintError

REGEX_POP_ID = re.compile(r'^"(?P<key>.+)" = \($')
REGEX_POP_CONTENT_HEADER = re.compile(r'^(?P<path>[/\w]+?)(?P<end>[{,)])$')
REGEX_ROW_BEGIN = re.compile(r'^\((?P<x>\d+),(?P<y>\d+),(?P<z>\d+)\) = {"$')
REGEX_VAR_EDIT = re.compile(r'^\t(?P<name>.+?) = (?P<definition>.+?);?$')

@dataclass
class Content:
    path: Typepath
    filename: str
    starting_line: int
    var_edits: dict[str, Constant] = field(default_factory = dict)

@dataclass
class DMM:
    pops: dict[str, list[Content]] = field(default_factory = dict)

    # Z -> X -> Y -> Pop
    turfs: list[list[list[str]]] = field(default_factory = list)

    def size(self):
        return (len(self.turfs[0]), len(self.turfs[0][0]))

    def turfs_for_pop(self, key: str):
        for z, z_level in enumerate(self.turfs):
            for x, x_level in enumerate(z_level):
                for y, turf in enumerate(x_level):
                    if turf == key:
                        yield (x, y, z)

class DMMParser:
    dmm: DMM
    line = 0

    def __init__(self, reader: IO):
        self.dmm = DMM()
        self.reader = reader

    def parse(self):
        if "dmm2tgm" not in self.next_line():
            self.raise_error("Map isn't in TGM format. Consider using StrongDMM instead of Dream Maker.\n  Please also consider installing the map merge tools, found through Install.bat in the tools/hooks folder.")

        try:
            while self.parse_pop():
                pass

            while self.parse_row():
                pass
        except MapParseError as error:
            raise self.raise_error(error)

        return self.dmm

    def next_line(self):
        self.line += 1

        try:
            return next(self.reader).removesuffix("\n")
        except StopIteration:
            return None

    def parse_pop(self):
        line = self.next_line()
        if line == "":
            return False

        pop_match = REGEX_POP_ID.match(line)
        if pop_match is None:
            self.raise_error("Pops ended too early, expected a newline in between.")

        pop_key = pop_match.group("key")
        contents = []

        while next_line := self.next_line():
            next_line = next_line.rstrip()
            content_match = REGEX_POP_CONTENT_HEADER.match(next_line)
            if content_match is None:
                self.raise_error("Pop content didn't lead to a path")

            content = Content(Typepath(content_match.group("path")), self.reader.name, self.line)
            contents.append(content)

            content_end = content_match.group("end")

            if content_end == ")":
                break
            elif content_end == "{":
                while (var_edit := self.parse_var_edit()) is not None:
                    content.var_edits[var_edit[0]] = var_edit[1]
            elif content_end == ",":
                continue

        self.dmm.pops[pop_key] = contents

        return True

    def parse_var_edit(self):
        line = self.next_line()
        if line == "\t},":
            return None

        var_edit_match = REGEX_VAR_EDIT.match(line)
        self.expect(var_edit_match is not None, "Var edits ended too early, expected a newline in between.")

        return (var_edit_match.group("name"), self.parse_constant(var_edit_match.group("definition")))

    def parse_constant(self, constant):
        if (float_constant := self.safe_float(constant)) is not None:
            return float_constant
        elif re.match(r'^/[/\w]+$', constant):
            return Typepath(constant)
        elif re.match(r'^".*"$', constant):
            # This should do escaping in the future
            return constant[1:-1]
        elif re.match(r'^null$', constant):
            return Null()
        elif re.match(r"^'.*'$", constant):
            return Filename(constant[1:-1])
        elif (list_match := re.match(r'^list\((?P<contents>.*)\)$', constant)):
            return ["NYI: list"]
        else:
            self.raise_error(f"Unknown constant type: {constant}")

    def parse_row(self):
        line = self.next_line()

        if line is None:
            return False

        if line == "":
            # Starting a new z level
            return True

        row_match = REGEX_ROW_BEGIN.match(line)
        self.expect(row_match is not None, "Rows ended too early, expected a newline in between.")
        self.expect(row_match.group("y") == "1", "TGM should only be producing individual rows.")

        x = int(row_match.group("x")) - 1
        z = int(row_match.group("z")) - 1

        if len(self.dmm.turfs) <= z:
            self.dmm.turfs.append([])
            self.expect(len(self.dmm.turfs) == z + 1, "Z coordinate is not sequential")

        z_level = self.dmm.turfs[z]
        self.expect(len(z_level) == x, "X coordinate is not sequential")

        contents = []

        while (next_line := self.next_line()) is not None:
            next_line = next_line.rstrip()
            if next_line == '"}':
                break

            self.expect(next_line in self.dmm.pops, f"Pop {next_line} is not defined")
            contents.append(next_line)

        z_level.append(contents)

        return True

    def safe_float(self, value):
        try:
            return float(value)
        except ValueError:
            return None

    def expect(self, condition, message):
        if not condition:
            self.raise_error(message)

    def raise_error(self, message):
        raise MaplintError(message, self.reader.name, self.line)

def parse_dmm(reader: IO):
    return DMMParser(reader).parse()
