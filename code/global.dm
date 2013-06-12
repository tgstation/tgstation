//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/global/obj/effect/datacore/data_core = null
var/global/obj/effect/overlay/plmaster = null
var/global/obj/effect/overlay/slmaster = null


var/global/list/machines = list()
var/global/list/processing_objects = list()
var/global/list/active_diseases = list()
		//items that ask to be called every cycle

var/global/defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

var/global/list/global_map = null
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
var/NEARSIGHTEDBLOCK = 0
var/EPILEPSYBLOCK = 0
var/COUGHBLOCK = 0
var/TOURETTESBLOCK = 0
var/NERVOUSBLOCK = 0
var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/STRANGEBLOCK = 0
var/RACEBLOCK = 0

var/list/bad_se_blocks
var/list/good_se_blocks
var/list/op_se_blocks

var/NULLED_SE
var/NULLED_UI

var/skipupdate = 0
	///////////////
var/eventchance = 3 //% per 5 mins
var/event = 0
var/hadevent = 0
var/blobevent = 0
	///////////////

var/diary = null
var/diaryofmeanpeople = null
var/href_logfile = null
var/station_name = null
var/game_version = "/tg/ Station 13"
var/changelog_hash = ""

var/going = 1.0
var/master_mode = "traitor"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/host = null
var/ooc_allowed = 1
var/dooc_allowed = 1
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


var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

var/shuttle_z = 2	//default
var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
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

var/shuttlecoming = 0

var/join_motd = null
var/forceblob = 0

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)

var/list/AAlarmWireColorToFlag = RandomAAlarmWires()
var/list/AAlarmIndexToFlag
var/list/AAlarmIndexToWireColor
var/list/AAlarmWireColorToIndex

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EX_DEVESTATION_RANGE = 3
var/MAX_EX_HEAVY_RANGE = 7
var/MAX_EX_LIGHT_RANGE = 14
var/MAX_EX_FLASH_RANGE = 14

var/list/liftable_structures = list(
	/obj/machinery/autolathe,
	/obj/machinery/constructable_frame,
	/obj/machinery/hydroponics,
	/obj/machinery/computer,
	/obj/structure/optable,
	/obj/structure/dispenser,
	/obj/machinery/gibber,
	/obj/machinery/microwave,
	/obj/machinery/vending,
	/obj/machinery/seed_extractor,
	/obj/machinery/space_heater,
	/obj/machinery/recharge_station,
	/obj/machinery/flasher,
	/obj/structure/stool,
	/obj/structure/closet,
	/obj/machinery/photocopier,
	/obj/structure/filingcabinet,
	/obj/structure/reagent_dispensers,
	/obj/machinery/portable_atmospherics/canister
	)
	//away missions
var/list/awaydestinations = list()	//a list of landmarks that the warpgate can take you to

	//radical shit
var/list/hit_appends = list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF")

	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
