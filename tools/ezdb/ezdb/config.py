from .paths import get_config_path
from typing import Optional

def read_config() -> Optional[dict[str, str]]:
    config_path = get_config_path()
    if not config_path.exists():
        return None

    with config_path.open('r') as file:
        lines = file.readlines()
        entries = {}

        for line in lines:
            if line.startswith("#"):
                continue
            if " " not in line:
                continue

            key, value = line.split(" ", 1)
            entries[key.strip()] = value.strip()

        return entries
