//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

var/obj/effect/datacore/data_core = null
var/obj/effect/overlay/plmaster = null
var/obj/effect/overlay/slmaster = null

	//obj/hud/main_hud1 = null

var/list/machines = list()
var/list/processing_objects = list()
var/list/active_diseases = list()
		//items that ask to be called every cycle

var/defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event


var/BLINDBLOCK = 0
var/DEAFBLOCK = 0
var/HULKBLOCK = 0
var/TELEBLOCK = 0
var/FIREBLOCK = 0
var/XRAYBLOCK = 0
var/CLUMSYBLOCK = 0
var/FAKEBLOCK = 0
var/BLOCKADD = 0
var/DIFFMUT = 0
var/HEADACHEBLOCK = 0
var/COUGHBLOCK = 0
var/TWITCHBLOCK = 0
var/NERVOUSBLOCK = 0
var/NOBREATHBLOCK = 0
var/REMOTEVIEWBLOCK = 0
var/REGENERATEBLOCK = 0
var/INCREASERUNBLOCK = 0
var/REMOTETALKBLOCK = 0
var/MORPHBLOCK = 0
var/BLENDBLOCK = 0
var/HALLUCINATIONBLOCK = 0
var/NOPRINTSBLOCK = 0
var/SHOCKIMMUNITYBLOCK = 0
var/SMALLSIZEBLOCK = 0
var/GLASSESBLOCK = 0
var/MONKEYBLOCK = 27

var/skipupdate = 0
	///////////////
var/eventchance = 1 //% per 2 mins
var/EventsOn = 1
var/hadevent = 0
var/blobevent = 0
	///////////////

var/diary = null
var/diaryofmeanpeople = null
var/href_logfile = null
var/station_name = null
var/game_version = "Baystation 12"

var/datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
var/going = 1.0
var/master_mode = "traitor"//"extended"
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
var/guests_allowed = 0
var/shuttle_frozen = 0
var/shuttle_left = 0
var/tinted_weldhelh = 1

var/list/jobMax = list()
var/list/bombers = list(  )
var/list/admin_log = list (  )
var/list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
var/list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
var/list/admins = list(  )
var/list/alien_whitelist = list(  )
var/list/shuttles = list(  )
var/list/reg_dna = list(  )
//	list/traitobj = list(  )


var/CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
var/CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

var/list/monkeystart = list()
var/list/wizardstart = list()
var/list/newplayer_start = list()
var/list/latejoin = list()
var/list/prisonwarp = list()	//prisoners go to these
var/list/holdingfacility = list()	//captured people go here
var/list/xeno_spawn = list()//Aliens spawn at these.
//	list/mazewarp = list()
var/list/tdome1 = list()
var/list/tdome2 = list()
var/list/tdomeobserve = list()
var/list/tdomeadmin = list()
var/list/prisonsecuritywarp = list()	//prison security goes to these
var/list/prisonwarped = list()	//list of players already warped
var/list/blobstart = list()
//	list/traitors = list()	//traitor list
var/list/cardinal = list( NORTH, SOUTH, EAST, WEST )
var/list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
var/list/emclosets = list()	//random emergency closets woo

var/datum/station_state/start_state = null
var/datum/configuration/config = null
var/datum/vote/vote = null
var/datum/sun/sun = null

var/list/combatlog = list()
var/list/IClog = list()
var/list/OOClog = list()
var/list/adminlog = list()


var/list/powernets = null

var/Debug = 0	// global debug switch
var/Debug2 = 0

var/datum/debug/debugobj

var/datum/moduletypes/mods = new()

var/wavesecret = 0

var/shuttlecoming = 0

var/join_motd = null
var/forceblob = 0

var/custom_event_msg = null

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
var/list/airlockWireColorToFlag = RandomAirlockWires()
var/list/airlockIndexToFlag
var/list/airlockIndexToWireColor
var/list/airlockWireColorToIndex
var/list/APCWireColorToFlag = RandomAPCWires()
var/list/APCIndexToFlag
var/list/APCIndexToWireColor
var/list/APCWireColorToIndex
var/list/BorgWireColorToFlag = RandomBorgWires()
var/list/BorgIndexToFlag
var/list/BorgIndexToWireColor
var/list/BorgWireColorToIndex
var/list/ScrambledFrequencies = list( ) //These are used for electrical storms, and anything else that jams radios.
var/list/UnscrambledFrequencies = list( )
var/list/AAlarmWireColorToFlag = RandomAAlarmWires() // Air Alarm hacking wires.
var/list/AAlarmIndexToFlag
var/list/AAlarmIndexToWireColor
var/list/AAlarmWireColorToIndex

var/list/paper_blacklist = list("script","frame","iframe","input","button","a","embed","object")

#define shuttle_time_in_station 1800 // 3 minutes in the station
#define shuttle_time_to_arrive 6000 // 10 minutes to arrive



	// MySQL configuration. You can also use the config/dbconfig.txt file.

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

/*	forumsqladdress = "localhost"
	forumsqlport = "3306"
	forumsqldb = "tgstation"
	forumsqllogin = "root"
	forumsqlpass = ""
	forum_activated_group = "2"
	forum_authenticated_group = "10"*/

	// For FTP requests. (i.e. downloading runtime logs.)
	// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 1800 //Cannot access files by ftp until the game is finished setting up and stuff.

// It turns out that /var/const can't handle lists, because lists use
// an initializer.  Sigh.  That's no reason that we shouldn't make
// actual "constant" lists explicit via naming convention and a
// separate location, though, so: below are all lists that should not
// ever be changed in code.

/var/global/AI_VERB_LIST = list(
		/mob/living/silicon/ai/proc/ai_call_shuttle,
		/mob/living/silicon/ai/proc/show_laws_verb,
		/mob/living/silicon/ai/proc/ai_camera_track,
		/mob/living/silicon/ai/proc/ai_alerts,
		/mob/living/silicon/ai/proc/ai_camera_list,
		/mob/living/silicon/ai/proc/ai_network_change,
		/mob/living/silicon/ai/proc/ai_statuschange,
		/mob/living/silicon/ai/proc/ai_hologram_change,
		/mob/living/silicon/ai/proc/ai_roster,
	)
