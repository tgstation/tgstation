import re
from dataclasses import dataclass

from .error import MapParseError

REGEX_TYPEPATH = re.compile(r'^/[\w/]+$')

class Typepath:
    path: str
    segments: list[str]

    def __init__(self, path):
        if not REGEX_TYPEPATH.match(path):
            raise MapParseError(f"Invalid typepath {path!r}.")

        self.path = path
        self.segments = path.split('/')[1:]

    def __eq__(self, other):
        if not isinstance(other, Typepath):
            return False

        return self.path == other.path

    def __str__(self) -> str:
        return self.path

@dataclass
class Filename:
    path: str

    def __str__(self) -> str:
        return self.path

@dataclass
class Null:
    def __str__(self) -> str:
        return "null"

Constant = str | float | Filename | Typepath | Null | list['Constant'] | dict['Constant', 'Constant']
