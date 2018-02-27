#!/usr/bin/env python3
import os

# Sort first by the directory part, then by the file extension, then by
# the file name itself. Files come before adjacent directories and dmf
# files follow dm files.
def comparison(path):
    parts = path.replace('\\', '/').split('/')
    parts = [['~~~', part.lower()] for part in parts]
    last = parts[-1]
    _, last[0] = os.path.splitext(last[1])
    return parts

BEGIN = "// BEGIN_INCLUDE"
END = "// END_INCLUDE"
PREFIX = '#include "'
SUFFIX = '"'

class DME:
    __slots__ = ['header', 'includes', 'footer']
    def __init__(self, f=None):
        self.header = []
        self.includes = []
        self.footer = []
        if not f:
            return
        f = iter(f)
        for line in f:
            self.header.append(line)
            if line.rstrip() == BEGIN:
                break
        for line in f:
            line, orig = line.rstrip(), line
            if line == END:
                self.footer.append(orig)
                break
            if not line.startswith(PREFIX) or not line.endswith(SUFFIX):
                raise RuntimeError(line)
            self.includes.append(line[len(PREFIX):-len(SUFFIX)])
        for line in f:
            self.footer.append(line)

    @staticmethod
    def from_file(path):
        with open(path) as f:
            return DME(f)

    def sort(self):
        self.includes.sort(key=comparison)

    def to_file(self, path):
        with open(path, 'w', newline='\r\n') as f:
            for line in self.header:
                f.write(line)
            for include in self.includes:
                f.write(f"{PREFIX}{include}{SUFFIX}\n")
            for line in self.footer:
                f.write(line)

def main(path):
    dme = DME.from_file(path)
    dme.sort()
    dme.to_file(path)

if __name__ == '__main__':
    main("tgstation.dme")
