import re
from typing import Optional, Union

from .common import Constant, Typepath
from .dmm import DMM, Content
from .error import MaplintError, MapParseError

def expect(condition, message):
    if not condition:
        raise MapParseError(message)

"""Create an error linked to a specific content instance"""
def fail_content(content: Content, message: str) -> MaplintError:
    return MaplintError(message, content.filename, content.starting_line)

class TypepathExtra:
    typepath: Typepath
    exact: bool = False
    wildcard: bool = False

    def __init__(self, typepath):
        if typepath == '*':
            self.wildcard = True
            return

        if typepath.startswith('='):
            self.exact = True
            typepath = typepath[1:]

        self.typepath = Typepath(typepath)

    def matches_path(self, path: Typepath):
        if self.wildcard:
            return True

        if self.exact:
            return self.typepath == path

        if len(self.typepath.segments) > len(path.segments):
            return False

        return self.typepath.segments == path.segments[:len(self.typepath.segments)]

class AtomNeighbor:
    identical: bool = False
    typepath: Optional[TypepathExtra] = None
    pattern: Optional[re.Pattern] = None

    def __init__(self, typepath, data = {}):
        if typepath.upper() != typepath:
            self.typepath = TypepathExtra(typepath)

        if data is None:
            return

        expect(isinstance(data, dict), "Banned neighbor must be a dictionary.")

        if "identical" in data:
            self.identical = data.pop("identical")
        expect(isinstance(self.identical, bool), "identical must be a boolean.")

        if "pattern" in data:
            self.pattern = re.compile(data.pop("pattern"))

        expect(len(data) == 0, f"Unknown key in banned neighbor: {', '.join(data.keys())}.")

    def matches(self, identified: Content, neighbor: Content):
        if self.identical:
            if identified.path != neighbor.path:
                return False

            if identified.var_edits != neighbor.var_edits:
                return False

            return True

        if self.typepath is not None:
            if self.typepath.matches_path(neighbor.path):
                return True

        if self.pattern is not None:
            if self.pattern.match(str(neighbor.path)):
                return True

        return False

    def to_string(self) -> str:
        if (self.typepath is not None):
            return self.typepath.typepath.path
        elif (self.pattern is not None):
            return self.pattern.pattern

Choices = list[Constant] | re.Pattern

def extract_choices(data, key) -> Optional[Choices]:
    if key not in data:
        return None

    constants_data = data.pop(key)

    if isinstance(constants_data, list):
        constants: list[Constant] = []

        for constant_data in constants_data:
            if isinstance(constant_data, str):
                constants.append(constant_data)
            elif isinstance(constant_data, int):
                constants.append(float(constant_data))
            elif isinstance(constant_data, float):
                constants.append(constant_data)

        return constants
    elif isinstance(constants_data, dict):
        if "pattern" in constants_data:
            pattern = constants_data.pop("pattern")
            return re.compile(pattern)

        raise MapParseError(f"Unknown key in {key}: {', '.join(constants_data.keys())}.")

    raise MapParseError(f"{key} must be a list of constants, or a pattern")

class BannedVariable:
    variable: str
    allow: Optional[Choices] = None
    deny: Optional[Choices] = None

    def __init__(self, variable, data = {}):
        self.variable = variable

        if data is None:
            return

        self.allow = extract_choices(data, "allow")
        self.deny = extract_choices(data, "deny")

        expect(len(data) == 0, f"Unknown key in banned variable {variable}: {', '.join(data.keys())}.")

    def run(self, identified: Content) -> str:
        if identified.var_edits[self.variable] is None:
            return None

        if self.allow is not None:
            if isinstance(self.allow, list):
                if identified.var_edits[self.variable] not in self.allow:
                    return f"Must be one of {', '.join(map(str, self.allow))}"
            elif not self.allow.match(str(identified.var_edits[self.variable])):
                return f"Must match {self.allow.pattern}"

            return None

        if self.deny is not None:
            if isinstance(self.deny, list):
                if identified.var_edits[self.variable] in self.deny:
                    return f"Must not be one of {', '.join(map(str, self.deny))}"
            elif self.deny.match(str(identified.var_edits[self.variable])):
                return f"Must not match {self.deny.pattern}"

            return None

        return f"This variable is not allowed for this type."

# Base class for conditional rules
class ConditionalRule:
    def is_met(self, identified: Content) -> bool:
        raise NotImplementedError("This method should be implemented by subclasses.")

    def match_string(self, parent_intersection: bool) -> str:
        raise NotImplementedError("This method should be implemented by subclasses")

# A single conditional expression
class WhenCondition(ConditionalRule):
    condition: str
    match_set: Optional[re.Match[str]]
    match_not_set: Optional[re.Match[str]]
    match_equal: Optional[re.Match[str]]
    match_not_equal: Optional[re.Match[str]]
    match_like: Optional[re.Match[str]]

    def __init__(self, condition: str):
        self.condition = condition
        self.match_set = re.match("(.+) is set", condition)
        self.match_not_set = re.match("(.+) is not set", condition)
        self.match_equal = re.match("(.+) is '(.+)'", condition)
        self.match_not_equal = re.match("(.+) is not '(.+)'", condition)
        self.match_like = re.match("(.+) like '(.+)'", condition)
        matches = 0
        if self.match_set is not None:
            matches = matches + 1
        if self.match_not_set is not None:
            matches = matches + 1
        if self.match_equal is not None:
            matches = matches + 1
        if self.match_not_equal is not None:
            matches = matches + 1
        if self.match_like is not None:
            matches = matches + 1
        if (matches != 1):
            raise RuntimeError(f"Conditional rule must be either is set, is not set, is 'value', is not 'value', or like 'regex'. Instead found: {condition}")

    def is_met(self, identified: Content) -> bool:
        var_edits = identified.var_edits

        if self.match_set is not None:
            var_name = self.match_set.group(1)
            return var_name in var_edits

        elif self.match_not_set is not None:
            var_name = self.match_not_set.group(1)
            return var_name not in var_edits

        elif self.match_equal is not None:
            var_name = self.match_equal.group(1)
            expected_value = self.match_equal.group(2)
            if var_name not in var_edits:
                return False
            if (isinstance(var_edits[var_name], float)):
                # If something is a float (number), check it as an int and a float
                # Hack for integer value parsing
                if var_edits[var_name] % 1 == 0:
                    return str(int(var_edits[var_name])).strip() == expected_value.strip()
            return str(var_edits[var_name]).strip() == expected_value.strip()

        elif self.match_not_equal is not None:
            var_name = self.match_not_equal.group(1)
            unexpected_value = self.match_not_equal.group(2)
            if var_name not in var_edits:
                return True
            if (isinstance(var_edits[var_name], float)):
                # If something is a float (number), check it as an int and a float
                # Hack for integer value parsing
                if var_edits[var_name] % 1 == 0:
                    return str(int(var_edits[var_name])).strip() != expected_value.strip()
            return str(var_edits[var_name]).strip() != expected_value.strip()

        elif self.match_like is not None:
            var_name = self.match_like.group(1)
            pattern = self.match_like.group(2)
            return (var_name in var_edits) and re.match(pattern, str(var_edits[var_name]))

        return False

    def match_string(self, parent_intersection: bool) -> str:
        return self.condition

# A conditional group (Joining with AND and OR)
class WhenGroup(ConditionalRule):
    conditions: list[ConditionalRule]
    all_group: bool

    def __init__(self, conditions: list[Union[dict, str]], all_group: bool = True):
        self.conditions = [self.parse_condition(condition) for condition in conditions]
        self.all_group = all_group

    def parse_condition(self, condition: Union[dict, str]) -> ConditionalRule:
        if isinstance(condition, dict):
            if "all" in condition:
                return WhenGroup(condition["all"], all_group=True)
            elif "any" in condition:
                return WhenGroup(condition["any"], all_group=False)
            else:
                raise RuntimeError(f"Unknown conditional group in when clause: {list(condition.keys())[0]}")
        elif isinstance(condition, str):
            return WhenCondition(condition)
        else:
            raise RuntimeError(f"Invalid condition type: {type(condition)}")

    def is_met(self, identified: Content) -> bool:
        if self.all_group:
            # For `all` group, all conditions must be met
            return all(condition.is_met(identified) for condition in self.conditions)
        else:
            # For `any` group, only one condition must be met
            return any(condition.is_met(identified) for condition in self.conditions)

    # Add parenthesis where required
    def match_string(self, parent_intersection: bool) -> str:
        match_symbol = " and " if self.all_group else " or "
        match_text = match_symbol.join(condition.match_string(self.all_group) for condition in self.conditions);
        if (self.all_group == False and parent_intersection == True and len(self.conditions) > 1):
            return f"({match_text})"
        else:
            return match_text

class When:
    root_group: WhenGroup

    def __init__(self, conditions: list[Union[dict, str]]):
        expect(isinstance(conditions, list), "when must be a list of conditions.")
        # Default to 'all' group if there are multiple conditions with no explicit 'any' or 'all'
        if len(conditions) > 1 and not any(isinstance(cond, dict) for cond in conditions):
            self.root_group = WhenGroup(conditions, all_group=True)
        else:
            self.root_group = WhenGroup(conditions)

    def evaluate(self, identified: Content) -> bool:
        return self.root_group.is_met(identified)

    def match_string(self) -> str:
        return f" when {self.root_group.match_string(True)}";

class Rules:
    banned: bool = False
    banned_neighbors: list[AtomNeighbor] = []
    banned_variables: bool | list[BannedVariable] = []
    required_neighbors: list[AtomNeighbor] = []
    when: Optional[When] = None

    def __init__(self, data):
        expect(isinstance(data, dict), "Lint rules must be a dictionary.")

        if "banned" in data:
            self.banned = data.pop("banned")
        expect(isinstance(self.banned, bool), "banned must be a boolean.")

        if "banned_neighbors" in data:
            banned_neighbors_data = data.pop("banned_neighbors")

            expect(isinstance(banned_neighbors_data, list) or isinstance(banned_neighbors_data, dict), "banned_neighbors must be a list, or a dictionary keyed by type.")

            if isinstance(banned_neighbors_data, dict):
                self.banned_neighbors = [AtomNeighbor(typepath, data) for typepath, data in banned_neighbors_data.items()]
            else:
                self.banned_neighbors = [AtomNeighbor(typepath) for typepath in banned_neighbors_data]

        if "required_neighbors" in data:
            required_neighbors_data = data.pop("required_neighbors")

            expect(isinstance(required_neighbors_data, list) or isinstance(required_neighbors_data, dict), "required_neighbors must be a list, or a dictionary keyed by type.")

            if isinstance(required_neighbors_data, dict):
                self.required_neighbors = [AtomNeighbor(typepath, data) for typepath, data in required_neighbors_data.items()]
            else:
                self.required_neighbors = [AtomNeighbor(typepath) for typepath in required_neighbors_data]

        if "banned_variables" in data:
            banned_variables_data = data.pop("banned_variables")
            if banned_variables_data == True:
                self.banned_variables = True
            else:
                expect(isinstance(banned_variables_data, list) or isinstance(banned_variables_data, dict), "banned_variables must be a list, or a dictionary keyed by variable.")

                if isinstance(banned_variables_data, dict):
                    self.banned_variables = [BannedVariable(variable, data) for variable, data in banned_variables_data.items()]
                else:
                    self.banned_variables = [BannedVariable(variable) for variable in banned_variables_data]

        if "when" in data:
            self.when = When(data.pop("when"))

        expect(len(data) == 0, f"Unknown lint rules: {', '.join(data.keys())}.")

    def run(self, identified: Content, contents: list[Content], identified_index) -> list[MaplintError]:
        failures: list[MaplintError] = []
        when_text = self.when.match_string() if self.when is not None else ""

        # If a when is present and is unmet, skip evaluation of this rule
        if self.when and not self.when.evaluate(identified):
            return failures

        if self.banned:
            failures.append(fail_content(identified, f"Typepath {identified.path} is banned{when_text}."))

        for banned_neighbor in self.banned_neighbors:
            for neighbor in contents[:identified_index] + contents[identified_index + 1:]:
                if not banned_neighbor.matches(identified, neighbor):
                    continue

                failures.append(fail_content(identified, f"Typepath {identified.path} has a banned neighbor{when_text}: {neighbor.path}"))

        for required_neighbor in self.required_neighbors:
            found = False
            for neighbor in contents[:identified_index] + contents[identified_index + 1:]:
                if required_neighbor.matches(identified, neighbor):
                    found = True
                    break
            if found == False:
                failures.append(fail_content(identified, f"Typepath {identified.path} is missing a required neighbor{when_text}: {required_neighbor.to_string()}"))

        if self.banned_variables == True:
            if len(identified.var_edits) > 0:
                failures.append(fail_content(identified, f"Typepath {identified.path} should not have any variable edits{when_text}."))
        else:
            assert isinstance(self.banned_variables, list)
            for banned_variable in self.banned_variables:
                if banned_variable.variable in identified.var_edits:
                    ban_reason = banned_variable.run(identified)
                    if ban_reason is None:
                        continue
                    failures.append(fail_content(identified, f"Typepath {identified.path} has a banned variable (set to {identified.var_edits[banned_variable.variable]}){when_text}: {banned_variable.variable}. {ban_reason}"))

        return failures

class Lint:
    help: Optional[str] = None
    rules: dict[TypepathExtra, Rules]
    disabled: bool = False

    def __init__(self, data):
        expect(isinstance(data, dict), "Lint must be a dictionary.")

        if "help" in data:
            self.help = data.pop("help")

        expect(isinstance(self.help, str) or self.help is None, "Lint help must be a string.")

        self.rules = {}

        for typepath, rules in data.items():
            self.rules[TypepathExtra(typepath)] = Rules(rules)

    def run(self, map_data: DMM) -> list[MaplintError]:
        all_failures: list[MaplintError] = []
        (width, height) = map_data.size()

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

                        x = coordinate[0] + 1
                        y = height - coordinate[1]
                        z = coordinate[2] + 1

                        coordinate_texts.append(f"({x}, {y}, {z})")

                    leftover_coordinates = sum(1 for _ in coordinates)
                    if leftover_coordinates > 0:
                        coordinate_texts.append(f"and {leftover_coordinates} more")

                    for failure in failures:
                        failure.coordinates = ', '.join(coordinate_texts)
                        failure.help = self.help
                        failure.pop_id = pop
                        all_failures.append(failure)

        return list(set(all_failures))
