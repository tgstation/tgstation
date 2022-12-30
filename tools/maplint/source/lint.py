from typing import Optional

from .common import Typepath
from .dmm import DMM, Content
from .error import MaplintError

def expect(condition, message):
    if not condition:
        raise MaplintError(message)

class TypepathExtra:
    typepath: Typepath
    wildcard: bool = False

    def __init__(self, typepath):
        if typepath == '*':
            self.wildcard = True
            return

        self.typepath = Typepath(typepath)

    def matches_path(self, path: Typepath):
        if self.wildcard:
            return True

        if len(self.typepath.segments) > len(path.segments):
            return False

        return self.typepath.segments == path.segments[:len(self.typepath.segments)]

class BannedNeighbor:
    identical: bool = False
    typepath: TypepathExtra

    def __init__(self, typepath, data = {}):
        self.typepath = TypepathExtra(typepath)

        expect(isinstance(data, dict), "Banned neighbor must be a dictionary.")

        if "identical" in data:
            self.identical = data.pop("identical")
        expect(isinstance(self.identical, bool), "identical must be a boolean.")

        expect(len(data) == 0, f"Unknown key in banned neighbor: {', '.join(data.keys())}.")

    def matches(self, identified: Content, neighbor: Content):
        if self.identical:
            return neighbor == identified

        return self.typepath.matches_path(neighbor.path)

class Rules:
    banned: bool = False
    banned_neighbors: list[BannedNeighbor] = []

    def __init__(self, data):
        expect(isinstance(data, dict), "Lint rules must be a dictionary.")

        if "banned" in data:
            self.banned = data.pop("banned")
        expect(isinstance(self.banned, bool), "banned must be a boolean.")

        if "banned_neighbors" in data:
            banned_neighbors_data = data.pop("banned_neighbors")

            expect(isinstance(banned_neighbors_data, list) or isinstance(banned_neighbors_data, dict), "banned_neighbors must be a list, or a dictionary keyed by type.")

            if isinstance(banned_neighbors_data, dict):
                self.banned_neighbors = [BannedNeighbor(typepath, data) for typepath, data in banned_neighbors_data.items()]
            else:
                self.banned_neighbors = [BannedNeighbor(typepath) for typepath in banned_neighbors_data]

        expect(len(data) == 0, f"Unknown lint rules: {', '.join(data.keys())}.")

    def run(self, identified, contents, identified_index) -> list[str]:
        failures = []

        if self.banned:
            failures.append(f"Typepath {identified.path} is banned.")

        for banned_neighbor in self.banned_neighbors:
            for neighbor in contents[:identified_index] + contents[identified_index + 1:]:
                if not banned_neighbor.matches(identified, neighbor):
                    continue

                failures.append(f"Typepath {identified.path} has a banned neighbor: {neighbor.path}")

        return failures

class Lint:
    help: Optional[str] = None
    rules: dict[TypepathExtra, Rules]

    def __init__(self, data):
        expect(isinstance(data, dict), "Lint must be a dictionary.")

        if "help" in data:
            self.help = data.pop("help")

        expect(isinstance(self.help, str) or self.help is None, "Lint help must be a string.")

        self.rules = {}

        for typepath, rules in data.items():
            self.rules[TypepathExtra(typepath)] = Rules(rules)

    def run(self, map_data: DMM):
        results = []

        for pop, contents in map_data.pops.items():
            for typepath_extra, rules in self.rules.items():
                for content_index, content in enumerate(contents):
                    if not typepath_extra.matches_path(content.path):
                        continue

                    failures = rules.run(content, contents, content_index)
                    if len(failures) == 0:
                        continue

                    coordinates = map_data.turfs_for_pop(pop)
                    coordinate_texts = []

                    for _ in range(3):
                        coordinate = next(coordinates, None)
                        if coordinate is None:
                            break
                        coordinate_texts.append(f"({coordinate[0] + 1}, {coordinate[1] + 1}, {coordinate[2] + 1})")

                    leftover_coordinates = sum(1 for _ in coordinates)
                    if leftover_coordinates > 0:
                        coordinate_texts.append(f"and {leftover_coordinates} more")

                    for failure in failures:
                        results.append(f"{failure}\n  Found at pop {pop} (found in {', '.join(coordinate_texts)})")

        return list(set(results))
