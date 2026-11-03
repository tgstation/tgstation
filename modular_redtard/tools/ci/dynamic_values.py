import os
import re

MODULE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
TYPE_LINE = re.compile(r"^(/datum/(?:special_intent|cleave_pattern)(?:/[a-z_]+)*)$")
VAR_LINE = re.compile(r"^\t(?:var/(?:list/)?)?([a-z_]+) = (.+)$")
SECONDS = re.compile(r"^(-?[\d.]+) SECONDS$")


def number(raw):
    raw = raw.strip()
    seconds = SECONDS.match(raw)
    if seconds:
        value = float(seconds.group(1)) * 10
    else:
        try:
            value = float(raw)
        except ValueError:
            return None
    return str(int(value)) if value == int(value) else repr(value)


def read_types(path):
    types = {}
    current = None
    for line in open(path, encoding="utf-8").read().split("\n"):
        found = TYPE_LINE.match(line)
        if found:
            current = types.setdefault(found.group(1), {})
            continue
        if not line.startswith("\t"):
            current = None
            continue
        if current is None:
            continue
        assigned = VAR_LINE.match(line)
        if assigned:
            current[assigned.group(1)] = assigned.group(2).strip()
    return types


def parent_of(path, types):
    declared = types.get(path, {}).get("parent_type")
    if declared:
        return declared
    return path.rsplit("/", 1)[0]


def resolve(path, name, types):
    while path and path.count("/") >= 2:
        if name in types.get(path, {}):
            return types[path][name]
        path = parent_of(path, types)
    return None


SPECIAL_FILES = ("specials.dm", "specials_azure.dm", "azure_weapons.dm")


def special_values():
    types = {}
    for name in SPECIAL_FILES:
        for path, found in read_types(os.path.join(MODULE, "combat", name)).items():
            types.setdefault(path, {}).update(found)
    out = []
    for path in sorted(types):
        if path == "/datum/special_intent":
            continue
        tunables = re.findall(r'"([a-z_]+)"', resolve(path, "tunables", types) or "")
        key = "special_" + path[len("/datum/special_intent/"):].replace("/", "_")
        name = (resolve(path, "name", types) or '""').strip('"')
        for tunable in tunables:
            value = number(resolve(path, tunable, types) or "0") or "0"
            out.append((f"{key}_{tunable}", value, f"{name}: {tunable}. Times are in deciseconds."))
    return out


def cleave_values():
    types = read_types(os.path.join(MODULE, "combat", "cleave.dm"))
    out = []
    for path in sorted(types):
        if path == "/datum/cleave_pattern":
            continue
        key = "cleave_" + path[len("/datum/cleave_pattern/"):].replace("/", "_") + "_max_targets"
        desc = (resolve(path, "desc", types) or '""').strip('"')
        out.append((key, number(resolve(path, "max_targets", types) or "1"), f"Most extra targets of a cleave: {desc}"))
    return out


def dynamic_values():
    return special_values() + cleave_values()


if __name__ == "__main__":
    for value_id, value, desc in dynamic_values():
        print(f"# {desc}\n{value_id} = {value}\n")
