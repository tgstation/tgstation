//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()		//stores only hair names
var/global/list/hair_styles_female_list = list()	//stores only hair names
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()	//stores only hair names
var/global/list/facial_hair_styles_female_list = list()	//stores only hair names
	//Underwear
var/global/list/underwear_list = list()		//stores /datum/sprite_accessory/underwear indexed by name
var/global/list/underwear_m = list()	//stores only underwear name
var/global/list/underwear_f = list()	//stores only underwear name
	//Undershirts
var/global/list/undershirt_list = list() 	//stores /datum/sprite_accessory/undershirt indexed by name
var/global/list/undershirt_m = list()	 //stores only undershirt name
var/global/list/undershirt_f = list()	 //stores only undershirt name
	//Socks
var/global/list/socks_list = list()		//stores /datum/sprite_accessory/socks indexed by name
	//Lizard Bits (all datum lists indexed by name)
var/global/list/body_markings_list = list()
var/global/list/tails_list_lizard = list()
var/global/list/animated_tails_list_lizard = list()
var/global/list/snouts_list = list()
var/global/list/horns_list = list()
var/global/list/frills_list = list()
var/global/list/spines_list = list()
var/global/list/legs_list = list()
var/global/list/animated_spines_list = list()

	//Mutant Human bits
var/global/list/tails_list_human = list()
var/global/list/animated_tails_list_human = list()
var/global/list/ears_list = list()
var/global/list/wings_list = list()
var/global/list/wings_open_list = list()
var/global/list/r_wings_list = list()

var/global/list/ghost_forms_with_directions_list = list("ghost") //stores the ghost forms that support directional sprites
var/global/list/ghost_forms_with_accessories_list = list("ghost") //stores the ghost forms that support hair and other such things

	//Backpacks
#define GBACKPACK "Grey Backpack"
#define GSATCHEL "Grey Satchel"
#define GDUFFLEBAG "Grey Dufflebag"
#define LSATCHEL "Leather Satchel"
#define DBACKPACK "Department Backpack"
#define DSATCHEL "Department Satchel"
#define DDUFFLEBAG "Department Dufflebag"
var/global/list/backbaglist = list(DBACKPACK, DSATCHEL, DDUFFLEBAG, GBACKPACK, GSATCHEL, GDUFFLEBAG, LSATCHEL)
	//Female Uniforms
var/global/list/female_clothing_icons = list()

	//radical shit
var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")

var/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')


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

var/list/TAGGERLOCATIONS = list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics")

var/global/list/guitar_notes = flist("sound/guitar/")

var/global/list/station_prefixes = list("", "Imperium", "Heretical", "Cuban",
	"Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique",
	"Houseruled", "Religious", "Atheist", "Traditional", "Houseruled",
	"Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death",
	"Zybourne", "Central", "Main", "Government", "Uoi", "Fat",
	"Automated", "Experimental", "Augmented")

var/global/list/station_names = list("", "Stanford", "Dorf", "Alium",
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
	"Robot", "Hats", "Pizza")

var/global/list/station_suffixes = list("Station", "Frontier",
	"Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk",
	"Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb",
	"Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive",
	"Complex", "Base", "Facility", "Depot", "Outpost", "Installation",
	"Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform",
	"Construct", "Hangar", "Prison", "Center", "Port", "Waystation",
	"Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object",
	"Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp",
	"Airstrip")

var/global/list/greek_letters = list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega")

var/global/list/phonetic_alphabet = list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu")

var/global/list/numbers_as_words = list("One", "Two", "Three", "Four",
	"Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
	"Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
	"Eighteen", "Nineteen")

/proc/generate_number_strings()
	var/list/L
	for(var/i in 1 to 99)
		L += "[i]"
		L += "\Roman[i]"
	return L

var/global/list/station_numerals = greek_letters + phonetic_alphabet + numbers_as_words + generate_number_strings()
