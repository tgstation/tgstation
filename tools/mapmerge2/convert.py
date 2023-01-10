#!/usr/bin/env python3
from . import frontend, dmm

if __name__ == '__main__':
    settings = frontend.read_settings()
    for fname in frontend.process(settings, "convert"):
        dmm.DMM.from_file(fname).to_file(fname, tgm = settings.tgm)
