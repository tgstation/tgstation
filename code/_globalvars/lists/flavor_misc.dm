//Preferences stuff
	//Hairstyles
var/global/list/hair_styles_list = list()			//stores /datum/sprite_accessory/hair indexed by name
var/global/list/hair_styles_male_list = list()		//stores only hair names
var/global/list/hair_styles_female_list = list()	//stores only hair names
var/global/list/facial_hair_styles_list = list()	//stores /datum/sprite_accessory/facial_hair indexed by name
var/global/list/facial_hair_styles_male_list = list()	//stores only hair names
var/global/list/facial_hair_styles_female_list = list()	//stores only hair names
	//Underwear
var/global/list/underwear_all = list()		//stores /datum/sprite_accessory/underwear indexed by name
var/global/list/underwear_m = list()	//stores only underwear name
var/global/list/underwear_f = list()	//stores only underwear name
	//Backpacks
var/global/list/backbaglist = list("Nothing", "Backpack", "Satchel")
	//Female Uniforms
var/global/list/female_uniform_icons = list()

	//radical shit
var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")

var/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')

//Alphabets
var/list/greekalphabet = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")
var/list/natoalphabet = list("Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf","Hotel","India","Juliette","Kilo","Lima","Mike","November","Oscar","Papa","Quebec","Romeo","Sierra","Tango","Uniform","Victor","Whiskey","X Ray","Yankee","Zulu")
var/list/oldmilitaryalphabet = list("Able","Baker","Charlie","Dog","Easy","Fox","George","How","Item","Jig","King","Love","Mike","Nan","Oboe","Peter","Queen","Roger","Sugar","Tare","Uncle","William","X Ray","Yoke","Zebra")

// Reference list for disposal sort junctions. Set the sortType variable on disposal sort junctions to
// the index of the sort department that you want. For example, sortType set to 2 will reroute all packages
// tagged for the Cargo Bay.//Your days are numbered TAGGERLOCATIONS list.
var/list/TAGGERLOCATIONS = list("Disposals",
	"Cargo Bay", "QM Office", "Engineering", "CE Office",
	"Atmospherics", "Security", "HoS Office", "Medbay",
	"CMO Office", "Chemistry", "Research", "RD Office",
	"Robotics", "HoP Office", "Library", "Chapel", "Theatre",
	"Bar", "Kitchen", "Hydroponics", "Janitor Closet","Genetics")
