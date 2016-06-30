#!/usr/bin/env python

import os
import os.path
import sys
import shutil
import argparse

import map_helpers

def is_tgm(filename):
    with open(filename) as f:
        header = f.readline()
        if header.find("//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE") != -1:
            return True
    return False


def get_filenames():
    filenames = []
    for path, folders, files in os.walk("_maps"):
        for file in sorted(files):
            if not file.endswith(".dmm"):
                continue
            filenames.append(os.path.join(path, file))
    return filenames

def doublecheck(verbose=False):
    success = True
    for filename1 in get_filenames():
        filename2 = filename1 + ".backup"
        tgm = is_tgm(filename1)

        with open(filename1) as f:
            original_contents = f.read()

        shutil.copyfile(filename1, filename2)
        try:
            did_merge = map_helpers.merge_map(filename1, filename2, tgm) != -1
        except KeyError:
            status = "Key Error"
            success = False

        if not did_merge:
            status = "Merge Error"
            success = False
        else:
            with open(filename1) as f2:
                new_contents = f2.read()
            if original_contents == new_contents:
                status = "Good"
            else:
                status = "Difference"
                success = False
        if status != "Good" or verbose:
            print("{}: {}".format(filename1, status))

    return success

if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-v','--verbose',action='store_true')
    args = parser.parse_args()
    success = doublecheck(verbose=args.verbose)
    if not success:
        sys.exit(1)
    else:
        sys.exit(0)
