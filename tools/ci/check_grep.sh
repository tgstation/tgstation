#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar

st=0

echo "Checking for map issues"
if grep -El '^\".+\" = \(.+\)' _maps/**/*.dmm;	then
    echo "ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!"
    st=1
fi;
if grep -P '//' _maps/**/*.dmm | grep -v '//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE' | grep -Ev 'name|desc'; then
	echo "ERROR: Unexpected commented out line detected in this map file. Please remove it."
	st=1
fi;
if grep -P 'Merge Conflict Marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;
# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
if grep -P '/obj/merge_conflict_marker' _maps/**/*.dmm; then
    echo "ERROR: Merge conflict markers detected in map, please resolve all merge failures!"
    st=1
fi;
if grep -P '^\ttag = \"icon' _maps/**/*.dmm;	then
    echo "ERROR: tag vars from icon state generation detected in maps, please remove them."
    st=1
fi;
if grep -P 'step_[xy]' _maps/**/*.dmm;	then
    echo "ERROR: step_x/step_y variables detected in maps, please remove them."
    st=1
fi;
if grep -P 'pixel_[^xy]' _maps/**/*.dmm;	then
    echo "ERROR: incorrect pixel offset variables detected in maps, please remove them."
    st=1
fi;
if grep -P '/obj/structure/cable(/\w+)+\{' _maps/**/*.dmm;	then
    echo "ERROR: vareditted cables detected, please remove them."
    st=1
fi;
if grep -P '\td[1-2] =' _maps/**/*.dmm;	then
    echo "ERROR: d1/d2 cable variables detected in maps, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/cable,\n[^)]*?/obj/structure/cable,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple cables on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple lattices on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/atmospherics/pipe/(?<type>[/\w]*),\n[^)]*?/obj/machinery/atmospherics/pipe/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical pipes on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/barricade/(?<type>[/\w]*),\n[^)]*?/obj/structure/barricade/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical barricades on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/table/(?<type>[/\w]*),\n[^)]*?/obj/structure/table/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical tables on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/chair/(?<type>[/\w]*),\n[^)]*?/obj/structure/chair/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical chairs on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple airlocks on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple firelocks on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/closet/(?<type>[/\w]*),\n[^)]*?/obj/structure/closet/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical closets on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/grille/(?<type>[/\w]*),\n[^)]*?/obj/structure/grille/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical grilles on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/girder/(?<type>[/\w]*),\n[^)]*?/obj/structure/girder/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical girders on the same tile, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/stairs/(?<type>[/\w]*),\n[^)]*?/obj/structure/stairs/\g{type},\n[^)]*?/area/.+\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found multiple identical stairs on the same tile, please remove them."
	st=1
fi;
if grep -rzoP 'machinery/door.*{([^}]|\n)*name = .*("|\s)(?!of|and|to)[a-z].*\n' _maps/**/*.dmm;	then
    echo
    echo "ERROR: found door names without proper upper-casing. Please upper-case your door names."
    st=1
fi;
if grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?\},?\n' _maps/**/*.dmm ||
	grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?\},?\n' _maps/**/*.dmm ||
	grep -Pzo '/obj/machinery/power/apc[/\w]*?\{\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?\},?\n' _maps/**/*.dmm ;	then
	echo
    echo "ERROR: found an APC with a manually set pixel_x or pixel_y that is not +-25."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed/wall[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found lattice stacked with a wall, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found lattice stacked within a wall, please remove them."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found a window stacked within a wall, please remove it."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found an airlock stacked within a wall, please remove it."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/obj/structure/stairs[/\w]*?,\n[^)]*?/turf/open/genturf[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found a staircase on top of a genturf. Please replace the genturf with a proper tile."
    st=1
fi;
if grep -Pzo '/obj/machinery/conveyor/inverted[/\w]*?\{\n[^}]*?dir = [1248];[^}]*?\},?\n' _maps/**/*.dmm;	then
	echo
    echo "ERROR: found an inverted conveyor belt with a cardinal dir. Please replace it with a normal conveyor belt."
    st=1
fi;
if grep -P '^/area/.+[\{]' _maps/**/*.dmm;	then
    echo "ERROR: Vareditted /area path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep -P '\W\/turf\s*[,\){]' _maps/**/*.dmm; then
    echo "ERROR: base /turf path use detected in maps, please replace with proper paths."
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm; then
    echo "ERROR: Multiple turfs detected on the same tile! Please choose only one turf!"
    st=1
fi;
if grep -Pzo '"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)' _maps/**/*.dmm; then
    echo "ERROR: Multiple areas detected on the same tile! Please choose only one area!"
    st=1
fi;
if grep -P '^/*var/' code/**/*.dm; then
    echo "ERROR: Unmanaged global var use detected in code, please use the helpers."
    st=1
fi;
echo "Checking for whitespace issues"
if grep -P '(^ {2})|(^ [^ * ])|(^    +)' code/**/*.dm; then
    echo "ERROR: space indentation detected"
    st=1
fi;
if grep -P '^\t+ [^ *]' code/**/*.dm; then
    echo "ERROR: mixed <tab><space> indentation detected"
    st=1
fi;
nl='
'
nl=$'\n'
while read f; do
    t=$(tail -c2 "$f"; printf x); r1="${nl}$"; r2="${nl}${r1}"
    if [[ ! ${t%x} =~ $r1 ]]; then
        echo "file $f is missing a trailing newline"
        st=1
    fi;
done < <(find . -type f -name '*.dm')
echo "Checking for common mistakes"
if grep -P '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' code/**/*.dm; then
    echo "changed files contains proc argument starting with 'var'"
    st=1
fi;
if grep 'balloon_alert\(".+"\)' code/**/*.dm; then
	echo "ERROR: Balloon alert with improper arguments."
	st=1
fi;
if grep -i 'centcomm' code/**/*.dm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in code, please remove the extra M(s)."
    st=1
fi;
if grep -i 'centcomm' _maps/**/*.dmm; then
    echo "ERROR: Misspelling(s) of CENTCOM detected in maps, please remove the extra M(s)."
    st=1
fi;
if grep -ni 'nanotransen' code/**/*.dm; then
    echo "Misspelling(s) of nanotrasen detected in code, please remove the extra N(s)."
    st=1
fi;
if grep -ni 'nanotransen' _maps/**/*.dmm; then
    echo "Misspelling(s) of nanotrasen detected in maps, please remove the extra N(s)."
    st=1
fi;
if ls _maps/*.json | grep -P "[A-Z]"; then
    echo "Uppercase in a map json detected, these must be all lowercase."
    st=1
fi;
if grep -i '/obj/effect/mapping_helpers/custom_icon' _maps/**/*.dmm; then
    echo "Custom icon helper found. Please include dmis as standard assets instead for built-in maps."
    st=1
fi;
for json in _maps/*.json
do
    map_path=$(jq -r '.map_path' $json)
    while read map_file; do
        filename="_maps/$map_path/$map_file"
        if [ ! -f $filename ]
        then
            echo "found invalid file reference to $filename in _maps/$json"
            st=1
        fi
    done < <(jq -r '[.map_file] | flatten | .[]' $json)
done

exit $st
