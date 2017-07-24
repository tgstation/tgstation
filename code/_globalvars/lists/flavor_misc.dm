//Preferences stuff
	//Hairstyles
GLOBAL_LIST_EMPTY(hair_styles_list)			//stores /datum/sprite_accessory/hair indexed by name
GLOBAL_LIST_EMPTY(hair_styles_male_list)		//stores only hair names
GLOBAL_LIST_EMPTY(hair_styles_female_list)	//stores only hair names
GLOBAL_LIST_EMPTY(facial_hair_styles_list)	//stores /datum/sprite_accessory/facial_hair indexed by name
GLOBAL_LIST_EMPTY(facial_hair_styles_male_list)	//stores only hair names
GLOBAL_LIST_EMPTY(facial_hair_styles_female_list)	//stores only hair names
	//Underwear
GLOBAL_LIST_EMPTY(underwear_list)		//stores /datum/sprite_accessory/underwear indexed by name
GLOBAL_LIST_EMPTY(underwear_m)	//stores only underwear name
GLOBAL_LIST_EMPTY(underwear_f)	//stores only underwear name
	//Undershirts
GLOBAL_LIST_EMPTY(undershirt_list) 	//stores /datum/sprite_accessory/undershirt indexed by name
GLOBAL_LIST_EMPTY(undershirt_m)	 //stores only undershirt name
GLOBAL_LIST_EMPTY(undershirt_f)	 //stores only undershirt name
	//Socks
GLOBAL_LIST_EMPTY(socks_list)		//stores /datum/sprite_accessory/socks indexed by name
	//Lizard Bits (all datum lists indexed by name)
GLOBAL_LIST_EMPTY(body_markings_list)
GLOBAL_LIST_EMPTY(tails_list_lizard)
GLOBAL_LIST_EMPTY(animated_tails_list_lizard)
GLOBAL_LIST_EMPTY(snouts_list)
GLOBAL_LIST_EMPTY(horns_list)
GLOBAL_LIST_EMPTY(frills_list)
GLOBAL_LIST_EMPTY(spines_list)
GLOBAL_LIST_EMPTY(legs_list)
GLOBAL_LIST_EMPTY(animated_spines_list)

	//Mutant Human bits
GLOBAL_LIST_EMPTY(tails_list_human)
GLOBAL_LIST_EMPTY(animated_tails_list_human)
GLOBAL_LIST_EMPTY(ears_list)
GLOBAL_LIST_EMPTY(wings_list)
GLOBAL_LIST_EMPTY(wings_open_list)
GLOBAL_LIST_EMPTY(r_wings_list)

GLOBAL_LIST_INIT(ghost_forms_with_directions_list, list("ghost")) //stores the ghost forms that support directional sprites
GLOBAL_LIST_INIT(ghost_forms_with_accessories_list, list("ghost")) //stores the ghost forms that support hair and other such things

GLOBAL_LIST_INIT(security_depts_prefs, list(SEC_DEPT_RANDOM, SEC_DEPT_NONE, SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY))

	//Backpacks
#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFELBAG "Grey Duffel Bag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFELBAG "Department Duffel Bag"
GLOBAL_LIST_INIT(backbaglist, list(DBACKPACK, DSATCHEL, DDUFFELBAG, GBACKPACK, GSATCHEL, GDUFFELBAG, LSATCHEL))

//Uplink spawn loc
#define UPLINK_PDA		"PDA"
#define UPLINK_RADIO	"Radio"
#define UPLINK_PEN		"Pen" //like a real spy!
GLOBAL_LIST_INIT(uplink_spawn_loc_list, list(UPLINK_PDA, UPLINK_RADIO, UPLINK_PEN))

	//Female Uniforms
GLOBAL_LIST_EMPTY(female_clothing_icons)

	//radical shit
GLOBAL_LIST_INIT(hit_appends, list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF"))

GLOBAL_LIST_INIT(scarySounds, list('sound/weapons/thudswoosh.ogg','sound/weapons/taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg','sound/items/welder.ogg','sound/items/welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg'))


// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.

/* List of sortType codes for mapping reference
0 Waste
1 Disposals
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
*/

GLOBAL_LIST_INIT(TAGGERLOCATIONS, list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics"))

GLOBAL_LIST_INIT(guitar_notes, flist("sound/guitar/"))

GLOBAL_LIST_INIT(station_prefixes, list("", "Imperium", "Heretical", "Cuban",
	"Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique",
	"Houseruled", "Religious", "Atheist", "Traditional", "Houseruled",
	"Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death",
	"Zybourne", "Central", "Main", "Government", "Uoi", "Fat",
	"Automated", "Experimental", "Augmented"))

GLOBAL_LIST_INIT(station_names, list("", "Stanford", "Dorf", "Alium",
	"Prefix", "Clowning", "Aegis", "Ishimura", "Scaredy", "Death-World",
	"Mime", "Honk", "Rogue", "MacRagge", "Ultrameens", "Safety", "Paranoia",
	"Explosive", "Neckbear", "Donk", "Muppet", "North", "West", "East",
	"South", "Slant-ways", "Widdershins", "Rimward", "Expensive",
	"Procreatory", "Imperial", "Unidentified", "Immoral", "Carp", "Ork",
	"Pete", "Control", "Nettle", "Aspie", "Class", "Crab", "Fist",
	"Corrogated","Skeleton","Race", "Fatguy", "Gentleman", "Capitalist",
	"Communist", "Bear", "Beard", "Derp", "Space", "Spess", "Star", "Moon",
	"System", "Mining", "Neckbeard", "Research", "Supply", "Military",
	"Orbital", "Battle", "Science", "Asteroid", "Home", "Production",
	"Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional",
	"Robot", "Hats", "Pizza"))

GLOBAL_LIST_INIT(station_suffixes, list("Station", "Frontier",
	"Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk",
	"Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb",
	"Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive",
	"Complex", "Base", "Facility", "Depot", "Outpost", "Installation",
	"Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform",
	"Construct", "Hangar", "Prison", "Center", "Port", "Waystation",
	"Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object",
	"Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp",
	"Airstrip"))

GLOBAL_LIST_INIT(greek_letters, list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega"))

GLOBAL_LIST_INIT(phonetic_alphabet, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu"))

GLOBAL_LIST_INIT(numbers_as_words, list("One", "Two", "Three", "Four",
	"Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
	"Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
	"Eighteen", "Nineteen"))

/proc/generate_number_strings()
	var/list/L[198]
	for(var/i in 1 to 99)
		L += "[i]"
		L += "\Roman[i]"
	return L

GLOBAL_LIST_INIT(station_numerals, greek_letters + phonetic_alphabet + numbers_as_words + generate_number_strings())

GLOBAL_LIST_INIT(admiral_messages, list("Do you know how expensive these stations are?","Stop wasting my time.","I was sleeping, thanks a lot.","Stand and fight you cowards!","You knew the risks coming in.","Stop being paranoid.","Whatever's broken just build a new one.","No.", "<i>null</i>","<i>Error: No comment given.</i>", "It's a good day to die!"))
