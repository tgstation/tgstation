from dataclasses import dataclass
from .paths import get_updates_path
import pathlib

@dataclass
class Change:
    major_version: int
    minor_version: int
    filepath: pathlib.Path

def get_changes() -> list[Change]:
    changes_path = get_updates_path()
    changes = []

    for path in changes_path.iterdir():
        if path.is_file():
            filename = path.name
            if not filename.endswith(".sql"):
                continue

            split_by_underscore = filename.split("_")
            major_version, minor_version = int(split_by_underscore[0]), int(split_by_underscore[1])
            changes.append(Change(int(major_version), int(minor_version), path))

    changes.sort(key=lambda change: (change.major_version, change.minor_version), reverse = True)

    return changes

def get_current_version():
    changes = get_changes()
    return (changes[0].major_version, changes[0].minor_version)
