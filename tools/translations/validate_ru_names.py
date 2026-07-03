import sys
import tomllib

from jsonschema import validate
from jsonschema.exceptions import ValidationError

STR = {"type": "string", "minLength": 1}
ENTRY = {
    "type": "object",
    "properties": {
        "nominative": STR,
        "genitive": STR,
        "dative": STR,
        "accusative": STR,
        "instrumental": STR,
        "prepositional": STR,
        "gender": {"type": "string", "enum": ["male", "female", "neuter", "plural"]},
    },
    "required": ["nominative"],
    "additionalProperties": False,
}

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(f"usage: {sys.argv[0]} <bundle.toml>")
    try:
        with open(sys.argv[1], "rb") as f:
            bundle = tomllib.load(f)
            validate(bundle, {"type": "object", "additionalProperties": ENTRY})
    except (tomllib.TOMLDecodeError, ValidationError) as err:
        print(err, file=sys.stderr)
        sys.exit(1)

    print(f"No translation issues found: {len(bundle)} entries in {sys.argv[1]}")
