# When passed an `init_times.json` file (received from enabling `PROFILE_MAPLOAD_INIT_ATOM`),
# and an optional max-depth level, this will output init times from worst to best.
import errno
import json
import sys

if len(sys.argv) < 2:
    print("Usage: read_init_times.py <init_times.json> [max_depth]")
    sys.exit(1)

max_depth = int(sys.argv[2]) if len(sys.argv) > 2 else 1000

with open(sys.argv[1], "r") as file:
    init_times = json.load(file)

init_times_per_type = {}

for (type, time) in init_times.items():
    type = '/'.join(type.split('/')[0:max_depth+1])
    init_times_per_type[type] = init_times_per_type.get(type, 0) + time

for (type, time) in sorted(init_times_per_type.items(), key = lambda x: x[1], reverse = True):
    try:
        print(type, time)
    except IOError as error:
        # Prevents broken pipe error if you do something like `read_init_times.py init_times.json | head`
        if error.errno == errno.EPIPE:
            sys.stderr.close()
            sys.exit(0)
