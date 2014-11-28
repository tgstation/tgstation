/mob
	density = 1
	layer = 4
	animate_movement = 2
	flags = NOREACT | HEAR
	hud_possible = list(ANTAG_HUD)
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/internals = null
	var/obj/screen/oxygen = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/toxin = null
	var/obj/screen/fire = null
	var/obj/screen/bodytemp = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/nutrition_icon = null
	var/obj/screen/pressure = null
	var/obj/screen/damageoverlay = null
	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null
	var/obj/screen/leap_icon = null

	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/notransform = null	//Carbon
	var/hand = null
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/real_name = null
	var/blinded = null
	var/bhunger = 0			//Carbon
	var/ajourn = 0
	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1
	var/eye_stat = null//Living, potentially Carbon
	var/lastpuke = 0
	var/unacidable = 0

	var/name_archive //For admin things like possession

	var/timeofdeath = 0//Living
	var/cpr_time = 1//Carbon


	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0//Carbon
	var/dizziness = 0//Carbon
	var/jitteriness = 0//Carbon
	var/nutrition = 400//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0
	var/stunned = 0
	var/weakened = 0
	var/losebreath = 0//Carbon
	var/shakecamera = 0
	var/a_intent = "help"//Living
	var/m_intent = "run"//Living
	var/lastKnownIP = null
	var/obj/structure/stool/bed/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/storage/s_active = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human
	var/see_override = 0 //0 for no override, sets see_invisible = see_override in mob life process

	var/datum/hud/hud_used = null

	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/music_lastplayed = "null"

	var/job = null//Living

	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon

	var/radiation = 0//Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"
	var/say_message = null // When you are understood by others. Currently only used by aliens and monkeys in their say_quote procs

	var/list/faction = list("neutral") //A list of factions that this mob is currently in, for hostile mob targetting, amongst other things
	var/move_on_shuttle = 1 // Can move on the shuttle.

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null


	var/list/mob_spell_list = list() //construct spells and mime spells. Spells that do not transfer from one mob to another and can not be lost in mindswap.

//Changlings, but can be used in other modes
//	var/obj/effect/proc_holder/changpower/list/power_list = list()

//List of active diseases

	var/list/viruses = list() // replaces var/datum/disease/virus

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 1 //Set to 1 to trigger update_icons() at the next life() call

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open

	var/force_compose = 0 //If this is nonzero, the mob will always compose it's own hear message instead of using the one given in the arguments.

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	var/turf/listed_turf = null	//the current turf being examined in the stat panel
	var/list/shouldnt_see = list() //list of objects that this mob shouldn't see. this silliness is needed because of AI alt+click and cult blood runes

