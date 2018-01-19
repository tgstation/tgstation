import sys
import re

TGM_HEADER = "//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"
BAD_VARS = ["step_x", "step_y", "d1", "d2"]
DICT_REGEX = r'"(.*)" = \('

def check_map(fp):
    """Checks a given map file(fp) for commom errors. Such as step_x/y and not being TGM."""
    map_lines = fp.readlines()
    current_line = 0 #keep track of the line so we can give meaningful errors
    current_dict = {'key' : '', 'members' : []} #Each members element will be a tuple with (line content, line number)
    if not map_lines[0].startswith(TGM_HEADER):
        raise TypeError("Map is not TGM. Please do the appropriate conversion.")
    for line in map_lines:
        dict_match = re.search(DICT_REGEX, line.replace('\n', ''))
        if dict_match:
            check_current_dict(current_dict)
            current_dict['key'] = dict_match.group(1)
            current_dict['members'] = []
        else:
            current_dict['members'].append((line, current_line))
        current_line += 1

def check_current_dict(current_dict):
    """Checks the current dict, before starting a new one, for the map errors"""
    has_turf = False
    has_area = False
    for member in current_dict['members']:
        if member[0].startswith('/turf'):
            if has_turf:
                raise Exception("Key has two or more turfs.", current_dict['key'], member[1])
            if member[0] == '/turf':
                raise Exception("Base turf detected, please use an appropriate turf type.")
            has_turf = True
        if member[0].startswith('/area'):
            if has_area:
                raise Exception("Key has two or more areas.", current_dict['key'], member[1])
            has_area = True
        #Check for vars that should not be used
        for bad in BAD_VARS:
            if member[0].find("\t" + bad + " = ") != -1:
                raise Exception("Bad variable: '{}' detected.".format(bad), current_dict['key'], member[1])
        

if __name__ == '__main__':
    with open(sys.argv[1]) as fp:
        try:
            check_map(fp)
        except Exception as exc:
            msg = fp.name + ": "
            if len(exc.args) > 2:
                msg += "(DICT KEY:{dict}|LINE:{line}): ".format(dict=exc.args[1], line=exc.args[2])
            msg += exc.args[0]
            print(msg)
            exit(1)
    exit(0)
