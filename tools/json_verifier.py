import sys
import json

if len(sys.argv) <= 1:
    exit(1)

files = filter(len, sys.argv[1].split('\n'))
msg = []
for file in files:
    with open(file, encoding="ISO-8859-1") as f:
        try:
            json.load(f)
        except ValueError as exception:
            msg.append("JSON synxtax error on file: {}".format(file))
            msg.append(str(exception))
if msg:
    print("\n".join(msg))
    exit(1)
exit(0)
