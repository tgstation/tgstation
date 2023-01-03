#!/bin/bash
set -euo pipefail

#nb: must be bash to support shopt globstar
shopt -s globstar extglob

#ANSI Escape Codes for colors to increase contrast of errors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

st=0

# check for ripgrep
if command -v rg >/dev/null 2>&1; then
	grep=rg
	pcre2_support=1
	if [ ! rg -P '' >/dev/null 2>&1 ] ; then
		pcre2_support=0
	fi
	code_files="code/**/**.dm"
	map_files="_maps/**/**.dmm"
	code_x_515="code/**/!(__byond_version_compat).dm"
else
	pcre2_support=0
	grep=grep
	code_files="-r --include=code/**/**.dm"
	map_files="-r --include=_maps/**/**.dmm"
	code_x_515="-r --include=code/**/!(__byond_version_compat).dm"
fi

echo -e "${BLUE}Using grep provider at $(which $grep)${NC}"

part=0
section() {
	echo -e "${BLUE}Checking for $1${NC}..."
	part=0
}

part() {
	part=$((part+1))
	padded=$(printf "%02d" $part)
	echo -e "${GREEN} $padded- $1${NC}"
}

section "map issues"

part "TGM"
if $grep -U '^".+" = \(.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Non-TGM formatted map detected. Please convert it using Map Merger!${NC}"
    st=1
fi;
part "comments"
if $grep '//' $map_files | $grep -v '//MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE' | $grep -v 'name|desc'; then
	echo
	echo -e "${RED}ERROR: Unexpected commented out line detected in this map file. Please remove it.${NC}"
	st=1
fi;
part "conflict markers"
if $grep 'Merge Conflict Marker' $map_files; then
	echo
    echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
    st=1
fi;
# We check for this as well to ensure people aren't actually using this mapping effect in their maps.
part "conflict marker object"
if $grep '/obj/merge_conflict_marker' $map_files; then
	echo
    echo -e "${RED}ERROR: Merge conflict markers detected in map, please resolve all merge failures!${NC}"
    st=1
fi;
part "iconstate tags"
if $grep '^\ttag = "icon' $map_files;	then
	echo
    echo -e "${RED}ERROR: Tag vars from icon state generation detected in maps, please remove them.${NC}"
    st=1
fi;
part "step varedits"
if $grep 'step_[xy]' $map_files;	then
	echo
    echo -e "${RED}ERROR: step_x/step_y variables detected in maps, please remove them.${NC}"
    st=1
fi;
part "pixel varedits"
if $grep 'pixel_[^xy]' $map_files;	then
	echo
    echo -e "${RED}ERROR: incorrect pixel offset variables detected in maps, please remove them.${NC}"
    st=1
fi;
part "varedited cables"
if $grep '/obj/structure/cable(/\w+)+[{]' $map_files;	then
	echo
    echo -e "${RED}ERROR: Variable editted cables detected, please remove them.${NC}"
    st=1
fi;
part "invalid map procs"
if $grep '(new|newlist|icon|matrix|sound)\(.+\)' $map_files;	then
	echo
	echo -e "${RED}ERROR: Using unsupported procs in variables in a map file! Please remove all instances of this.${NC}"
	st=1
fi;
part "invalid cables"
if $grep '\td[1-2] =' $map_files;	then
	echo
    echo -e "${RED}ERROR: d1/d2 cable variables detected in maps, please remove them.${NC}"
    st=1
fi;
part "multiple cables"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/cable,\n[^)]*?/obj/structure/cable,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found multiple cables on the same tile, please remove them.${NC}"
    st=1
fi;
part "multiple lattices"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found multiple lattices on the same tile, please remove them.${NC}"
    st=1
fi;
part "multiple airlocks"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found multiple airlocks on the same tile, please remove them.${NC}"
    st=1
fi;
part "multiple firelocks"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/obj/machinery/door/firedoor[/\w]*?,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found multiple firelocks on the same tile, please remove them.${NC}"
    st=1
fi;
part "apc pixel shifts"
if $grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?[013-9]\d*?[^\d]*?\s*?[}],?\n' $map_files ||
	$grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d+?[0-46-9][^\d]*?\s*?[}],?\n' $map_files ||
	$grep -U '/obj/machinery/power/apc[/\w]*?[{]\n[^}]*?pixel_[xy] = -?\d{3,1000}[^\d]*?\s*?[}],?\n' $map_files ;	then
	echo
    echo -e "${RED}ERROR: Found an APC with a manually set pixel_x or pixel_y that is not +-25. Use the directional variants when possible.${NC}"
    st=1
fi;
part "lattice and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed/wall[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked with a wall, please remove them.${NC}"
    st=1
fi;
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/lattice[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a lattice stacked within a wall, please remove them.${NC}"
    st=1
fi;
part "window and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/window[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a window stacked within a wall, please remove it.${NC}"
    st=1
fi;
part "airlock and wall stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/machinery/door/airlock[/\w]*?,\n[^)]*?/turf/closed[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found an airlock stacked within a wall, please remove it.${NC}"
    st=1
fi;
part "genturf with staircases"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/stairs[/\w]*?,\n[^)]*?/turf/open/genturf[/\w]*?,\n[^)]*?/area/.+?\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a staircase on top of a gen_turf. Please replace the gen_turf with a proper turf.${NC}"
    st=1
fi;
part "grilles on cables"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/cable,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a grille above a cable. Please replace with the proper structure spawner.${NC}"
    st=1
fi;
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/cable,\n[^)]*?/obj/structure/grille,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found a grille above a cable. Please replace with the proper structure spawner.${NC}"
    st=1
fi;
part "grille and window stacking"
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/reinforced/fulltile/ice,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found grille above a fulltile ice window. Please replace it with the proper structure spawner.${NC}"
    st=1
fi;
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window[/\w]*?fulltile,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found grille above a fulltile window. Please replace it with the proper structure spawner.${NC}"
    st=1
fi;
if $grep -U '"\w+" = \(\n[^)]*?/obj/structure/grille,\n[^)]*?/obj/structure/window/reinforced/plasma/plastitanium,\n[^)]*?/area/.+\)' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found grille above a fulltile plastitanium window. Please replace it with the proper structure spawner.${NC}"
    st=1
fi;
part "converyor cardinals inversion"
if $grep -U '/obj/machinery/conveyor/inverted[/\w]*?[{]\n[^}]*?dir = [1248];[^}]*?[}],?\n' $map_files;	then
	echo
    echo -e "${RED}ERROR: Found an inverted conveyor belt with a cardinal dir. Please replace it with a normal conveyor belt.${NC}"
    st=1
fi;
part "area varedits"
if $grep '^/area/.+[{]' $map_files;	then
	echo
    echo -e "${RED}ERROR: Variable editted /area path use detected in a map, please replace with a proper area path.${NC}"
    st=1
fi;
part "base turf type"
if $grep '/turf\s*[,\){]' $map_files; then
	echo
    echo -e "${RED}ERROR: Base /turf path use detected in maps, please replace it with a proper turf path.${NC}"
    st=1
fi;
part "multiple turfs"
if $grep -U '"\w+" = \(\n[^)]*?/turf/[/\w]*?,\n[^)]*?/turf/[/\w]*?,\n[^)]*?/area/.+?\)' $map_files; then
	echo
    echo -e "${RED}ERROR: Multiple turfs detected on the same tile! Please choose only one turf!${NC}"
    st=1
fi;
part "multiple areas"
if $grep -U '"\w+" = \(\n[^)]*?/area/.+?,\n[^)]*?/area/.+?\)' $map_files; then
	echo
    echo -e "${RED}ERROR: Multiple areas detected on the same tile! Please choose only one area!${NC}"
    st=1
fi;
part "common spelling mistakes"
if $grep -i 'nanotransen' $map_files; then
	echo
    echo -e "${RED}ERROR: Misspelling of Nanotrasen detected in maps, please remove the extra N(s).${NC}"
    st=1
fi;
if $grep -i'centcomm' $map_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in maps, please remove the extra M(s).${NC}"
    st=1
fi;

section "whitespace issues"
part "space indentation"
if $grep '(^ {2})|(^ [^ * ])|(^    +)' $code_files; then
	echo
    echo -e "${RED}ERROR: Space indentation detected, please use tab indentation.${NC}"
    st=1
fi;
part "mixed indentation"
if $grep '^\t+ [^ *]' $code_files; then
	echo
    echo -e "${RED}ERROR: Mixed <tab><space> indentation detected, please stick to tab indentation.${NC}"
    st=1
fi;

section "unit tests"
part "mob/living/carbon/human usage"
if $grep 'allocate\(/mob/living/carbon/human[,\)]' code/modules/unit_tests/**/**.dm ||
	$grep 'new /mob/living/carbon/human\s?\(' ||
	$grep 'var/mob/living/carbon/human/\w+\s?=\s?new' ; then
	echo
	echo -e "${RED}ERROR: Usage of mob/living/carbon/human detected in a unit test, please use mob/living/carbon/human/consistent.${NC}"
	st=1
fi;

section "common mistakes"
part "global vars"
if $grep '^/*var/' $code_files; then
	echo
    echo -e "${RED}ERROR: Unmanaged global var use detected in code, please use the helpers.${NC}"
    st=1
fi;
part "proc args with var/"
if $grep '^/[\w/]\S+\(.*(var/|, ?var/.*).*\)' $code_files; then
	echo
    echo -e "${RED}ERROR: Changed files contains a proc argument starting with 'var'.${NC}"
    st=1
fi;

part "balloon_alert sanity"
if $grep 'balloon_alert\(".*"\)' $code_files; then
	echo
	echo -e "${RED}ERROR: Found a balloon alert with improper arguments.${NC}"
	st=1
fi;

if $grep 'balloon_alert(.*span_)' $code_files; then
	echo
	echo -e "${RED}ERROR: Balloon alerts should never contain spans.${NC}"
	st=1
fi;

part "balloon_alert idiomatic usage"
if $grep 'balloon_alert\(.*?, ?"[A-Z]' $code_files; then
	echo
	echo -e "${RED}ERROR: Balloon alerts should not start with capital letters. This includes text like 'AI'. If this is a false positive, wrap the text in UNLINT().${NC}"
	st=1
fi;

part "common spelling mistakes"
if $grep -i 'centcomm' $code_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of CentCom detected in code, please remove the extra M(s).${NC}"
    st=1
fi;
if $grep -ni 'nanotransen' $code_files; then
	echo
    echo -e "${RED}ERROR: Misspelling(s) of Nanotrasen detected in code, please remove the extra N(s).${NC}"
    st=1
fi;
part "map json naming"
if ls _maps/*.json | $grep "[A-Z]"; then
	echo
    echo -e "${RED}ERROR: Uppercase in a map .JSON file detected, these must be all lowercase.${NC}"
    st=1
fi;
part "custom icon helpers"
if $grep -i '/obj/effect/mapping_helpers/custom_icon' $map_files; then
	echo
    echo -e "${RED}ERROR: Custom icon helper found. Please include DMI files as standard assets instead for repository maps.${NC}"
    st=1
fi;
part "map json sanity"
for json in _maps/*.json
do
    map_path=$(jq -r '.map_path' $json)
    while read map_file; do
        filename="_maps/$map_path/$map_file"
        if [ ! -f $filename ]
        then
			echo
            echo -e "${RED}ERROR: Found an invalid file reference to $filename in _maps/$json ${NC}"
            st=1
        fi
    done < <(jq -r '[.map_file] | flatten | .[]' $json)
done

section "515 Proc Syntax"
part "proc ref syntax"
if $grep '\.proc/' $code_x_515 ; then
    echo
    echo -e "${RED}ERROR: Outdated proc reference use detected in code, please use proc reference helpers.${NC}"
    st=1
fi;

if [ "$pcre2_support" -eq 1 ]; then
	section "regexes requiring PCRE2"
	part "multiple pipes"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/machinery/atmospherics/pipe/(?<type>[/\w]*),\n[^)]*?/obj/machinery/atmospherics/pipe/\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical pipes on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple barricades"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/barricade(?<type>[/\w]*),\n[^)]*?/obj/structure/barricade\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical barricades on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple tables"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/table(?<type>[/\w]*),\n[^)]*?/obj/structure/table\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical tables on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple closets"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/closet(?<type>[/\w]*),\n[^)]*?/obj/structure/closet\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical closets on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple grilles"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/grille(?<type>[/\w]*),\n[^)]*?/obj/structure/grille/\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical grilles on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple girders"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/girder(?<type>[/\w]*),\n[^)]*?/obj/structure/girder\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical girders on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "multiple stairs"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/stairs/(?<type>[/\w]*),\n[^)]*?/obj/structure/stairs/\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical stairs on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "door names"
	if $grep -PU '/obj/machinery/door.*{([^}]|\n)*name = .*("|\s)(?!of|and|to)[a-z].*\n' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found door names without proper upper-casing. Please upper-case your door names.${NC}"
		st=1
	fi;
	part "multiple chairs"
	if $grep -PU '"\w+" = \(\n[^)]*?/obj/structure/chair(?<type>[/\w]*),\n[^)]*?/obj/structure/chair\g{type},\n[^)]*?/area/.+\)' $map_files;	then
		echo
		echo -e "${RED}ERROR: Found multiple identical chairs on the same tile, please remove them.${NC}"
		st=1
	fi;
	part "to_chat sanity"
	if $grep -P 'to_chat\((?!.*,).*\)' $code_files; then
		echo
		echo -e "${RED}ERROR: to_chat() missing arguments.${NC}"
		st=1
	fi;
	part "timer flag sanity"
	if $grep -P 'addtimer\((?=.*TIMER_OVERRIDE)(?!.*TIMER_UNIQUE).*\)' $code_files; then
		echo
		echo -e "${RED}ERROR: TIMER_OVERRIDE used without TIMER_UNIQUE.${NC}"
		st=1
	fi
	part "trailing newlines"
	if $grep -PU '[^\n]$(?!\n)' $code_files; then
		echo
		echo -e "${RED}ERROR: File(s) with no trailing newline detected, please add one.${NC}"
		st=1
	fi
	part "docking_port varedits"
	if $grep -PU '^/obj/docking_port/mobile.*\{\n[^}]*(width|height|dwidth|dheight)[^}]*[}]' $map_files; then
		echo
		echo -e "${RED}ERROR: Custom mobile docking_port sizes detected. This is done automatically and should not be varedits."
		echo -e "\t\tPlease remove the width, height, dwidth, and dheight varedits from the docking_port.${NC}"
		st=1
	fi;
else
	echo -e "${RED}pcre2 not supported, skipping checks requiring pcre2"
	echo -e "if you want to run these checks install ripgrep with pcre2 support.${NC}"
fi

if [ $st = 0 ]; then
    echo
    echo -e "${GREEN}No errors found using $grep!${NC}"
fi;

if [ $st = 1 ]; then
    echo
    echo -e "${RED}Errors found, please fix them and try again.${NC}"
fi;

exit $st
