import re
import os
import argparse
import map_helpers #why we don't have some generic package for these reee

default_map_directory = "../../_maps"
replacement_re = re.compile('\s*([^{]*)\s*(\{(.*)\})?')

def tgm_check(map_file):
    with open(map_file) as f:
        firstline = f.readline()
        #why some maps have trailing spaces in this ???
        if firstline.startswith(map_helpers.tgm_header):
            return True
        return False

def save_map(map_data,filepath,tgm=False):
    map_data['dictionary'] = map_helpers.sort_dictionary(map_data['dictionary'])
    if tgm:
        map_helpers.write_dictionary_tgm(filepath, map_data['dictionary'],None)
        map_helpers.write_grid_coord_small(filepath, map_data['grid'], map_data['maxx'], map_data['maxy'])
    else:
        map_helpers.write_dictionary(filepath, map_data['dictionary'],None)
        map_helpers.write_grid(filepath, map_data['grid'], map_data['maxx'], map_data['maxy'])

def update_all_maps(update_file=None, update_string=None, map_directory=None, verbose=False):
    if map_directory is None:
        map_directory = os.path.normpath(os.path.join(os.path.dirname(__file__), default_map_directory))
    for root, _, files in os.walk(map_directory):
        for filepath in files:
            if filepath.endswith(".dmm"):
                path = os.path.join(root, filepath)
                update_map(path, update_file, update_string, verbose)

def update_map(map_filepath, update_file=None, update_string=None, verbose=False):
    print("Updating: {0}".format(map_filepath))
    map_data = map_helpers.parse_map(map_helpers.get_map_raw_text(map_filepath))
    tgm = tgm_check(map_filepath)
    if update_file:
        with open(update_file) as update_source:
            for line in update_source:
                if line.startswith("#") or line.isspace():
                    continue
                map_data = update_path(map_data, line, verbose)
                save_map(map_data, map_filepath, tgm)
    if update_string:
        map_data = update_path(map_data, update_string, verbose)
        save_map(map_data, map_filepath, tgm)

def props_to_string(props):
    return "{{{0}}}".format(";".join([k+" = "+props[k] for k in props]))

#urgent todo: replace with actual parser, this is slow as janitor in crit
split_re = re.compile('((?:[A-Za-z0-9_\-$]+)\s*=\s*(?:"(?:.+?)"|[^";]*)|@OLD)')

def string_to_props(propstring,verbose = False):
    props = dict()
    for raw_prop in re.split(split_re,propstring):
        if not raw_prop or raw_prop.strip() == ';':
            continue
        prop = raw_prop.split('=', maxsplit=1)
        props[prop[0].strip()] = prop[1].strip() if len(prop) > 1 else None
    if verbose:
        print("{0} to {1}".format(propstring,props))
    return props

def parse_rep_string(replacement_string,verbose = False):
    # translates /blah/blah {meme = "test",} into path,prop dictionary tuple
    match = re.match(replacement_re, replacement_string)
    path = match.group(1)
    props = match.group(3)
    if props:
        prop_dict = string_to_props(props, verbose)
    else:
        prop_dict = dict()
    return path.strip(), prop_dict

def update_path(mapdata, replacement_string, verbose=False):
    old_path_part, new_path_part = replacement_string.split(':', maxsplit=1)
    old_path, old_path_props = parse_rep_string(old_path_part,verbose)
    new_paths = dict()
    for replacement_def in new_path_part.split(','):
        new_path, new_path_props = parse_rep_string(replacement_def,verbose)
        new_paths[new_path] = new_path_props

    def replace_def(match):
        if match.group(2):
            old_props = string_to_props(match.group(2),verbose)
        else:
            old_props = dict()
        for filter_prop in old_path_props:
            if filter_prop not in old_props:
                if old_path_props[filter_prop] == "@UNSET":
                    continue
                else:
                    return [match.group(0)]
            else:
                if old_props[filter_prop] != old_path_props[filter_prop] or old_path_props[filter_prop] == "@UNSET":
                    return [match.group(0)] #does not match current filter, skip the change.
        if verbose:
            print("Found match : {0}".format(match.group(0)))
        out_paths = []
        for new_path, new_props in new_paths.items():
            out = new_path
            out_props = dict()
            for prop_name, prop_value in new_props.items():
                if prop_name == "@OLD":
                    out_props = dict(old_props)
                    continue
                if prop_value == "@SKIP":
                    out_props.pop(prop_name, None)
                    continue
                if prop_value.startswith("@OLD"):
                    params = prop_value.split(":")
                    if prop_name in old_props:
                        out_props[prop_name] = old_props[params[1]] if len(params) > 1 else old_props[prop_name]
                    continue
                out_props[prop_name] = prop_value
            if out_props:
                out += props_to_string(out_props)
            out_paths.append(out)
        if verbose:
            print("Replacing with: {0}".format(out_paths))
        return out_paths

    def get_result(element):
        p = re.compile("{0}\s*({{(.*)}})?$".format(re.escape(old_path)))
        match = p.match(element)
        if match:
            return replace_def(match) # = re.sub(p,replace_def,element)
        else:
            return [element]

    for definition_key in mapdata['dictionary']:
        def_value = mapdata['dictionary'][definition_key]
        start = list(def_value)
        changed = [y for x in start for y in get_result(x)]
        new_value = tuple(changed)
        if new_value != def_value:
            mapdata['dictionary'][definition_key] = new_value

    return mapdata

if __name__ == "__main__":
    desc = """
    Update dmm files given update file/string.

    Replacement syntax example:
        /turf/open/floor/plasteel/warningline : /obj/effect/turf_decal {dir = @OLD ;tag = @SKIP;icon_state = @SKIP}
        /turf/open/floor/plasteel/warningline : /obj/effect/turf_decal {@OLD} , /obj/thing {icon_state = @OLD:name; name = "meme"}
        /turf/open/floor/plasteel/warningline{dir=2} : /obj/thing
    New paths properties:
        @OLD - if used as property name copies all modified properties from original path to this one
        property = @SKIP - will not copy this property through when global @OLD is used.
        property = @OLD - will copy this modified property from original object even if global @OLD is not used
        property = @OLD:name - will copy [name] property from original object even if global @OLD is not used
        Anything else is copied as written.
    Old paths properties:
        Will be used as a filter.
        property = @UNSET - will apply the rule only if the property is not mapedited
    """

    parser = argparse.ArgumentParser(description=desc, formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("update_source", help="update file path / line of update notation")
    parser.add_argument("--map", "-m", help="path to update, defaults to all maps in maps directory")
    parser.add_argument("--directory", "-d", help="path to maps directory, defaults to ../../_maps")
    parser.add_argument("--inline", "-i", help="treat update source as update string instead of path", action="store_true")
    parser.add_argument("--verbose", "-v", help="toggle detailed update information", action="store_true")

    args = parser.parse_args()
    if args.directory:
        default_map_directory = args.directory

    if args.map:
        if args.inline:
            update_map(args.map, update_string=args.update_source, verbose=args.verbose)
        else:
            update_map(args.map, update_file=args.update_source, verbose=args.verbose)
    else:
        if args.inline:
            update_all_maps(update_string=args.update_source, verbose=args.verbose)
        else:
            update_all_maps(update_file=args.update_source, verbose=args.verbose)
