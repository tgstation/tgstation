GLOBAL_LIST_INIT(color_list_ethereal, list(
	"Blue" = "#3399ff",
	"Bright Yellow" = "#ffff99",
	"Burnt Orange" = "#cc4400",
	"Cyan Blue" = "#00ffff",
	"Dark Blue" = "#6666ff",
	"Dark Fuschia" = "#cc0066",
	"Dark Green" = "#37835b",
	"Dark Red" = "#9c3030",
	"Dull Yellow" = "#fbdf56",
	"Faint Blue" = "#b3d9ff",
	"Faint Green" = "#ddff99",
	"Faint Red" = "#ffb3b3",
	"Green" = "#97ee63",
	"Orange" = "#ffa64d",
	"Pink" = "#ff99cc",
	"Purple" = "#ee82ee",
	"Red" = "#ff4d4d",
	"Seafoam Green" = "#00fa9a",
	"White" = "#f2f2f2",
))

GLOBAL_LIST_INIT(color_list_lustrous, list(
	"Cyan Blue" = "#00ffff",
	"Sky Blue" = "#37c0ff",
	"Blue" = "#3374ff",
	"Dark Blue" = "#5b5beb",
	"Bright Red" = "#fa2d2d",
))

GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list(
	"catghost",
	"ghost_black",
	"ghost_blazeit",
	"ghost_blue",
	"ghost_camo",
	"ghost_cyan",
	"ghost_dblue",
	"ghost_dcyan",
	"ghost_dgreen",
	"ghost_dpink",
	"ghost_dred",
	"ghost_dyellow",
	"ghost_fire",
	"ghost_funkypurp",
	"ghost_green",
	"ghost_grey",
	"ghost_mellow",
	"ghost_pink",
	"ghost_pinksherbert",
	"ghost_purpleswirl",
	"ghost_rainbow",
	"ghost_red",
	"ghost_yellow",
	"ghost",
	"ghostian",
	"ghostian2",
	"ghostking",
	"skeleghost",
))
//stores the ghost forms that support directional sprites

GLOBAL_LIST_INIT(ghost_forms_with_accessories_list, list(
	"ghost_black",
	"ghost_blazeit",
	"ghost_blue",
	"ghost_camo",
	"ghost_cyan",
	"ghost_dblue",
	"ghost_dcyan",
	"ghost_dgreen",
	"ghost_dpink",
	"ghost_dred",
	"ghost_dyellow",
	"ghost_fire",
	"ghost_funkypurp",
	"ghost_green",
	"ghost_grey",
	"ghost_mellow",
	"ghost_pink",
	"ghost_pinksherbert",
	"ghost_purpleswirl",
	"ghost_rainbow",
	"ghost_red",
	"ghost_yellow",
	"ghost",
	"skeleghost",
))
//stores the ghost forms that support hair and other such things

GLOBAL_LIST_INIT(security_depts_prefs, sort_list(list(
	SEC_DEPT_ENGINEERING,
	SEC_DEPT_MEDICAL,
	SEC_DEPT_NONE,
	SEC_DEPT_SCIENCE,
	SEC_DEPT_SUPPLY,
)))

	//Backpacks
#define DBACKPACK "Department Backpack"
#define DDUFFELBAG "Department Duffel Bag"
#define DSATCHEL "Department Satchel"
#define DMESSENGER "Department Messenger Bag"
#define GBACKPACK "Grey Backpack"
#define GDUFFELBAG "Grey Duffel Bag"
#define GSATCHEL "Grey Satchel"
#define GMESSENGER "Grey Messenger Bag"
#define LSATCHEL "Leather Satchel"
GLOBAL_LIST_INIT(backpacklist, list(
	DBACKPACK,
	DDUFFELBAG,
	DSATCHEL,
	DMESSENGER,
	GBACKPACK,
	GDUFFELBAG,
	GSATCHEL,
	GMESSENGER,
	LSATCHEL,
))

	//Suit/Skirt
#define PREF_SUIT "Jumpsuit"
#define PREF_SKIRT "Jumpskirt"

//Uplink spawn loc
#define UPLINK_PDA "PDA"
#define UPLINK_RADIO "Radio"
#define UPLINK_PEN "Pen" //like a real spy!
#define UPLINK_IMPLANT "Implant"

	//Female Uniforms
GLOBAL_LIST_EMPTY(female_clothing_icons)

GLOBAL_LIST_INIT(scarySounds, list(
	'sound/effects/footstep/clownstep1.ogg',
	'sound/effects/footstep/clownstep2.ogg',
	'sound/effects/glass/glassbr1.ogg',
	'sound/effects/glass/glassbr2.ogg',
	'sound/effects/glass/glassbr3.ogg',
	'sound/items/tools/welder.ogg',
	'sound/items/tools/welder2.ogg',
	'sound/machines/airlock/airlock.ogg',
	'sound/mobs/non-humanoids/hiss/hiss1.ogg',
	'sound/mobs/non-humanoids/hiss/hiss2.ogg',
	'sound/mobs/non-humanoids/hiss/hiss3.ogg',
	'sound/mobs/non-humanoids/hiss/hiss4.ogg',
	'sound/mobs/non-humanoids/hiss/hiss5.ogg',
	'sound/mobs/non-humanoids/hiss/hiss6.ogg',
	'sound/items/weapons/armbomb.ogg',
	'sound/items/weapons/taser.ogg',
	'sound/items/weapons/thudswoosh.ogg',
	'sound/items/weapons/shove.ogg',
))


// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

/* List of sortType codes for mapping reference
0 Waste
1 Disposals - All unwrapped items and untagged parcels get picked up by a junction with this sortType. Usually leads to the recycler.
2 Cargo Bay
3 QM Office
4 Engineering
5 CE Office
6 Atmospherics
7 Security
8 HoS Office
9 Medbay
10 CMO Office
11 Chemistry
12 Research
13 RD Office
14 Robotics
15 HoP Office
16 Library
17 Chapel
18 Theatre
19 Bar
20 Kitchen
21 Hydroponics
22 Janitor
23 Genetics
24 Experimentor Lab
25 Ordnance
26 Dormitories
27 Virology
28 Xenobiology
29 Law Office
30 Detective's Office
*/

//The whole system for the sorttype var is determined based on the order of this list,
//disposals must always be 1, since anything that's untagged will automatically go to disposals, or sorttype = 1 --Superxpdude

//If you don't want to fuck up disposals, add to this list, and don't change the order.
//If you insist on changing the order, you'll have to change every sort junction to reflect the new order. --Pete

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics",
	"Experimentor Lab", "Ordnance", "Dormitories", "Virology",
	"Xenobiology", "Law Office","Detective's Office"))

GLOBAL_LIST_INIT(station_prefixes, world.file2list("strings/station_prefixes.txt"))

GLOBAL_LIST_INIT(station_names, world.file2list("strings/station_names.txt"))

GLOBAL_LIST_INIT(station_suffixes, world.file2list("strings/station_suffixes.txt"))

GLOBAL_LIST_INIT(greek_letters, world.file2list("strings/greek_letters.txt"))

GLOBAL_LIST_INIT(phonetic_alphabet, world.file2list("strings/phonetic_alphabet.txt"))

GLOBAL_LIST_INIT(numbers_as_words, world.file2list("strings/numbers_as_words.txt"))

GLOBAL_LIST_INIT(wisdoms, world.file2list("strings/wisdoms.txt"))

/proc/generate_number_strings()
	var/list/L[198]
	for(var/i in 1 to 99)
		L += "[i]"
		L += "\Roman[i]"
	return L

GLOBAL_LIST_INIT(station_numerals, greek_letters + phonetic_alphabet + numbers_as_words + generate_number_strings())

GLOBAL_LIST_INIT(admiral_messages, list(
	"<i>Error: No comment given.</i>",
	"<i>null</i>",
	"Do you know how expensive these stations are?",
	"I was sleeping, thanks a lot.",
	"It's a good day to die!",
	"No.",
	"Stand and fight you cowards!",
	"Stop being paranoid.",
	"Stop wasting my time.",
	"Whatever's broken just build a new one.",
	"You knew the risks coming in.",
))

GLOBAL_LIST_INIT(junkmail_messages, world.file2list("strings/junkmail.txt"))

// All valid inputs to status display post_status
GLOBAL_LIST_INIT(status_display_approved_pictures, list(
	"blank",
	"shuttle",
	"default",
	"biohazard",
	"lockdown",
	"greenalert",
	"bluealert",
	"redalert",
	"deltaalert",
	"radiation",
	"currentalert", //For automatic set of status display on current level
))

// Members of status_display_approved_pictures that are actually states and not alert values
GLOBAL_LIST_INIT(status_display_state_pictures, list(
	"blank",
	"shuttle",
))

GLOBAL_LIST_INIT(fishing_tips, world.file2list("strings/fishing_tips.txt"))
