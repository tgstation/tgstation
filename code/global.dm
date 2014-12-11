//#define TESTING
//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// List of types and how many instances of each type there are.
var/global/list/type_instances[0]

var/global/obj/effect/datacore/data_core = null
var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null


var/global/list/machines = list()
var/global/list/processing_objects = list()
var/global/list/active_diseases = list()
var/global/list/events = list()

var/global/list/account_DBs = list()

var/global/datum/map_data/map_info = new()//defined in each .dm file in /maps/. only include to the dme the one of the map you are about to compile. do not include the map in the .dme anymore.

		//items that ask to be called every cycle

var/global/defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

var/global/list/global_map = null

var/global/datum/universal_state/universe = new

	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space


	//////////////
var/list/paper_tag_whitelist = list("center","p","div","span","h1","h2","h3","h4","h5","h6","hr","pre",	\
	"big","small","font","i","u","b","s","sub","sup","tt","br","hr","ol","ul","li","caption","col",	\
	"table","td","th","tr")
var/list/paper_blacklist = list("java","onblur","onchange","onclick","ondblclick","onfocus","onkeydown",	\
	"onkeypress","onkeyup","onload","onmousedown","onmousemove","onmouseout","onmouseover",	\
	"onmouseup","onreset","onselect","onsubmit","onunload")

var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/COUGHBLOCK = 0
var/GLASSESBLOCK = 0
var/EPILEPSYBLOCK = 0
var/TWITCHBLOCK = 0
var/NERVOUSBLOCK = 0
var/MONKEYBLOCK = 50 // Monkey block will always be the DNA_SE_LENGTH

var/BLOCKADD = 0
var/DIFFMUT = 0

var/HEADACHEBLOCK = 0
var/NOBREATHBLOCK = 0
var/REMOTEVIEWBLOCK = 0
var/REGENERATEBLOCK = 0
var/INCREASERUNBLOCK = 0
var/REMOTETALKBLOCK = 0
var/MORPHBLOCK = 0
var/COLDBLOCK = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK = 0

///////////////////////////////
// Goon Stuff
///////////////////////////////
// Disabilities
var/LISPBLOCK = 0
var/MUTEBLOCK = 0
var/RADBLOCK = 0
var/FATBLOCK = 0
var/CHAVBLOCK = 0
var/SWEDEBLOCK = 0
var/SCRAMBLEBLOCK = 0
var/TOXICFARTBLOCK = 0
var/STRONGBLOCK = 0
var/HORNSBLOCK = 0
var/SMILEBLOCK = 0
var/ELVISBLOCK = 0

// Powers
var/SOBERBLOCK = 0
var/PSYRESISTBLOCK = 0
var/SHADOWBLOCK = 0
var/CHAMELEONBLOCK = 0
var/CRYOBLOCK = 0
var/EATBLOCK = 0
var/JUMPBLOCK = 0
var/MELTBLOCK = 0
var/EMPATHBLOCK = 0
var/SUPERFARTBLOCK = 0
var/IMMOLATEBLOCK = 0
var/POLYMORPHBLOCK = 0

///////////////////////////////
// /vg/ Mutations
///////////////////////////////
var/LOUDBLOCK = 0
var/WHISPERBLOCK = 0
var/DIZZYBLOCK = 0
var/SANSBLOCK = 0




var/skipupdate = 0
	///////////////
var/eventchance = 10 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////
var/starticon = null
var/midicon = null
var/endicon = null
var/diary = null
var/diaryofmeanpeople = null
var/admin_diary = null
var/href_logfile = null
var/station_name = null
var/game_version = "adsfasdfasdf"
var/changelog_hash = ""
var/game_year = (text2num(time2text(world.realtime, "YYYY")) + 544)

var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
var/going = 1.0
var/master_mode = "extended"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/datum/engine_eject/engine_eject_control = null
var/host = null
var/aliens_allowed = 1
var/ooc_allowed = 1
var/dooc_allowed = 1
var/traitor_scaling = 1
//var/goonsay_allowed = 0
var/dna_ident = 1
var/abandon_allowed = 1
var/enter_allowed = 1
var/guests_allowed = 1
var/shuttle_frozen = 0
var/shuttle_left = 0
var/tinted_weldhelh = 1

var/list/jobMax = list()
var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/shuttles = list(  )
var/list/reg_dna = list(  )
//	list/traitobj = list(  )

var/mouse_respawn_time = 1 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

// COORDINATE OFFSETS
// Used for telescience.  Only apply to GPSes and other things that display coordinates to players.
// The idea is that coordinates given will be entirely different from those displayed on the map in DreamMaker,
//  while still making it very simple to lock onto someone who is drifting in space.
var/WORLD_X_OFFSET=0
var/WORLD_Y_OFFSET=0

var/shuttle_z = 2	//default
var/airtunnel_start = 68 // default
var/airtunnel_stop = 68 // default
var/airtunnel_bottom = 72 // default
var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/endgame_safespawns = list()
var/list/endgame_exits = list()
var/list/meteor_materialkit = list()
var/list/meteor_bombkit = list()
var/list/meteor_bombkitextra = list()
var/list/meteor_tankkit = list()
var/list/meteor_canisterkit = list()
var/list/meteor_buildkit = list()
var/list/meteor_pizzakit = list()
var/list/meteor_panickit = list()
var/list/meteor_shieldkit = list()
var/list/meteor_genkit = list()
var/list/meteor_breachkit = list()
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
var/list/ninjastart = list()
//	list/traitors = list()	//traitor list
var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)

var/datum/station_state/start_state = null
var/datum/configuration/config = null
var/datum/sun/sun = null

var/list/combatlog = list()
var/list/IClog = list()
var/list/OOClog = list()
var/list/adminlog = list()


var/list/powernets = list()

var/Debug = 0	// global debug switch
var/Debug2 = 0

var/datum/debug/debugobj

var/datum/moduletypes/mods = new()

var/wavesecret = 0
var/gravity_is_on = 1

var/shuttlecoming = 0

var/join_motd = null
var/forceblob = 0

// nanomanager, the manager for Nano UIs
var/datum/nanomanager/nanomanager = new()

#define SPEED_OF_LIGHT 3e8 //not exact but hey!
#define SPEED_OF_LIGHT_SQ 9e+16
#define FIRE_DAMAGE_MODIFIER 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
#define AIR_DAMAGE_MODIFIER 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
#define INFINITY 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
#define MAX_MESSAGE_LEN 1024
#define MAX_PAPER_MESSAGE_LEN 3072
#define MAX_BOOK_MESSAGE_LEN 9216
#define MAX_NAME_LEN 26
#define MAX_BROADCAST_LEN		512

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive

	//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqldb = "tgstation"
var/sqllogin = "root"
var/sqlpass = ""

	// Feedback gathering sql connection

var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""

var/sqllogging = 0 // Should we log deaths, population stats, etc?



	// Forum MySQL configuration (for use with forum account/key authentication)
	// These are all default values that will load should the forumdbconfig.txt
	// file fail to read for whatever reason.

var/forumsqladdress = "localhost"
var/forumsqlport = "3306"
var/forumsqldb = "tgstation"
var/forumsqllogin = "root"
var/forumsqlpass = ""
var/forum_activated_group = "2"
var/forum_authenticated_group = "10"

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
var/DBConnection/dbcon_old = new()	//Tgstation database (Old database) - See the files in the SQL folder for information what goes where.

#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

// Recall time limit:  2 hours
var/recall_time_limit=72000

//Goonstyle scoreboard
// NOW AN ASSOCIATIVE LIST
// NO FUCKING EXCUSE FOR THE ATROCITY THAT WAS
var/list/score=list(
	"crewscore"      = 0, // this is the overall var/score for the whole round
	"stuffshipped"   = 0, // how many useful items have cargo shipped out?
	"stuffharvested" = 0, // how many harvests have hydroponics done?
	"oremined"       = 0, // obvious
	"researchdone"   = 0,
	"eventsendured"  = 0, // how many random events did the station survive?
	"powerloss"      = 0, // how many APCs have poor charge?
	"escapees"       = 0, // how many people got out alive?
	"deadcrew"       = 0, // dead bodies on the station, oh no
	"mess"           = 0, // how much poo, puke, gibs, etc went uncleaned
	"meals"          = 0,
	"disease"        = 0, // how many rampant, uncured diseases are on board the station
	"deadcommand"    = 0, // used during rev, how many command staff perished
	"arrested"       = 0, // how many traitors/revs/whatever are alive in the brig
	"traitorswon"    = 0, // how many traitors were successful?
	"allarrested"    = 0, // did the crew catch all the enemies alive?
	"opkilled"       = 0, // used during nuke mode, how many operatives died?
	"disc"           = 0, // is the disc safe and secure?
	"nuked"          = 0, // was the station blown into little bits?

	// these ones are mainly for the stat panel
	"powerbonus"    = 0, // if all APCs on the station are running optimally, big bonus
	"messbonus"     = 0, // if there are no messes on the station anywhere, huge bonus
	"deadaipenalty" = 0, // is the AI dead? if so, big penalty
	"foodeaten"     = 0, // nom nom nom
	"clownabuse"    = 0, // how many times a clown was punched, struck or otherwise maligned
	"richestname"   = null, // this is all stuff to show who was the richest alive on the shuttle
	"richestjob"    = null,  // kinda pointless if you dont have a money system i guess
	"richestcash"   = 0,
	"richestkey"    = null,
	"dmgestname"    = null, // who had the most damage on the shuttle (but was still alive)
	"dmgestjob"     = null,
	"dmgestdamage"  = 0,
	"dmgestkey"     = null
)