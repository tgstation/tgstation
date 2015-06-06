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
var/global/list/socks_m = list()	 //stores only socks name
var/global/list/socks_f = list()	 //stores only socks name
	//Lizard Bits (all datum lists indexed by name)
var/global/list/body_markings_list = list()
var/global/list/tails_list = list()
var/global/list/snouts_list = list()
var/global/list/horns_list = list()
var/global/list/frills_list = list()
var/global/list/spines_list = list()
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel")
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