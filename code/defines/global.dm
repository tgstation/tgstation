var/global
	obj/datacore/data_core = null
	obj/effect/overlay/plmaster = null
	obj/effect/overlay/slmaster = null

	//obj/hud/main_hud1 = null

	list/machines = list()
	list/processing_objects = list()
	list/active_diseases = list()
		//items that ask to be called every cycle

	defer_powernet_rebuild = 0		// true if net rebuild will be called manually after an event

	//list/global_map = null //Borked, do not touch. DMTG
	//list/global_map = list(list(1,5),list(4,3))//an array of map Z levels.
	//Resulting sector map looks like
	//|_1_|_4_|
	//|_5_|_3_|
	//
	//1 - SS13
	//4 - Derelict
	//3 - AI satellite
	//5 - empty space

var

	//////////////

	BLINDBLOCK = 0
	DEAFBLOCK = 0
	HULKBLOCK = 0
	TELEBLOCK = 0
	FIREBLOCK = 0
	XRAYBLOCK = 0
	CLUMSYBLOCK = 0
	FAKEBLOCK = 0
	BLOCKADD = 0
	DIFFMUT = 0
	HEADACHEBLOCK = 0
	COUGHBLOCK = 0
	TWITCHBLOCK = 0
	NERVOUSBLOCK = 0
	NOBREATHBLOCK = 0
	REMOTEVIEWBLOCK = 0
	REGENERATEBLOCK = 0
	INCREASERUNBLOCK = 0
	REMOTETALKBLOCK = 0
	MORPHBLOCK = 0
	BLENDBLOCK = 0
	HALLUCINATIONBLOCK = 0
	NOPRINTSBLOCK = 0
	SHOCKIMMUNITYBLOCK = 0
	SMALLSIZEBLOCK = 0
	GLASSESBLOCK = 0
	MONKEYBLOCK = 27

	skipupdate = 0
	///////////////
	eventchance = 1 //% per 2 mins
	EventsOn = 1
	hadevent = 0
	blobevent = 0
	///////////////

	diary = null
	diaryofmeanpeople = null
	station_name = null
	game_version = "Baystation 12"

	datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
	going = 1.0
	master_mode = "traitor"//"extended"
	secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

	datum/engine_eject/engine_eject_control = null
	host = null
	aliens_allowed = 1
	ooc_allowed = 1
	dooc_allowed = 1
	traitor_scaling = 1
	goonsay_allowed = 0
	dna_ident = 1
	abandon_allowed = 1
	enter_allowed = 1
//	guests_allowed = 1
	shuttle_frozen = 0
	shuttle_left = 0
	tinted_weldhelh = 1

	list/jobMax = list()
	list/bombers = list(  )
	list/admin_log = list (  )
	list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
	list/lawchanges = list(  ) //Stores who uploaded laws to which silicon-based lifeform, and what the law was
	list/admins = list(  )
	list/alien_whitelist = list(  )
	list/shuttles = list(  )
	list/reg_dna = list(  )
//	list/traitobj = list(  )


	CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
	CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

	shuttle_z = 2	//default
	airtunnel_start = 68 // default
	airtunnel_stop = 68 // default
	airtunnel_bottom = 72 // default
	list/monkeystart = list()
	list/wizardstart = list()
	list/newplayer_start = list()
	list/latejoin = list()
	list/prisonwarp = list()	//prisoners go to these
	list/holdingfacility = list()	//captured people go here
	list/xeno_spawn = list()//Aliens spawn at these.
//	list/mazewarp = list()
	list/tdome1 = list()
	list/tdome2 = list()
	list/tdomeobserve = list()
	list/tdomeadmin = list()
	list/prisonsecuritywarp = list()	//prison security goes to these
	list/prisonwarped = list()	//list of players already warped
	list/blobstart = list()
//	list/traitors = list()	//traitor list
	list/cardinal = list( NORTH, SOUTH, EAST, WEST )
	list/alldirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	list/emclosets = list()	//random emergency closets woo

	datum/station_state/start_state = null
	datum/configuration/config = null
	datum/vote/vote = null
	datum/sun/sun = null

	list/combatlog = list()
	list/IClog = list()
	list/OOClog = list()
	list/adminlog = list()


	list/powernets = null

	Debug = 0	// global debug switch
	Debug2 = 0

	datum/debug/debugobj

	datum/moduletypes/mods = new()

	wavesecret = 0

	shuttlecoming = 0

	join_motd = null
	rules = null
	forceblob = 0

	custom_event_msg = null

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = RandomAirlockWires()
	list/airlockIndexToFlag
	list/airlockIndexToWireColor
	list/airlockWireColorToIndex
	list/APCWireColorToFlag = RandomAPCWires()
	list/APCIndexToFlag
	list/APCIndexToWireColor
	list/APCWireColorToIndex
	list/BorgWireColorToFlag = RandomBorgWires()
	list/BorgIndexToFlag
	list/BorgIndexToWireColor
	list/BorgWireColorToIndex
	list/ScrambledFrequencies = list( ) //These are used for electrical storms, and anything else that jams radios.
	list/UnscrambledFrequencies = list( )
	list/AAlarmWireColorToFlag = RandomAAlarmWires() // Air Alarm hacking wires.
	list/AAlarmIndexToFlag
	list/AAlarmIndexToWireColor
	list/AAlarmWireColorToIndex

	const/SPEED_OF_LIGHT = 3e8 //not exact but hey!
	const/SPEED_OF_LIGHT_SQ = 9e+16
	const/FIRE_DAMAGE_MODIFIER = 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
	const/AIR_DAMAGE_MODIFIER = 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
	const/INFINITY = 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
	const/MAX_MESSAGE_LEN = 1024
	const/MAX_PAPER_MESSAGE_LEN = 3072
	const/MAX_BOOK_MESSAGE_LEN = 9216

	const/MAX_NAME_LEN = 26

	list/paper_blacklist = list("script","frame","iframe","input","button","a","embed","object")

	const/shuttle_time_in_station = 1800 // 3 minutes in the station
	const/shuttle_time_to_arrive = 6000 // 10 minutes to arrive



	// MySQL configuration. You can also use the config/dbconfig.txt file.

	sqladdress = "localhost"
	sqlport = "3306"
	sqldb = "tgstation"
	sqllogin = "root"
	sqlpass = ""

	// Feedback gathering sql connection

	sqlfdbkdb = "test"
	sqlfdbklogin = "root"
	sqlfdbkpass = ""

	sqllogging = 0 // Should we log deaths, population stats, etc?



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
	fileaccess_timer = 1800 //Cannot access files by ftp until the game is finished setting up and stuff.

// It turns out that /var/const can't handle lists, because lists use
// an initializer.  Sigh.  That's no reason that we shouldn't make
// actual "constant" lists explicit via naming convention and a
// separate location, though, so: below are all lists that should not
// ever be changed in code.

/var/global
	AI_VERB_LIST = list(
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