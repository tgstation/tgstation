/mob
	density = 1
	layer = 4
	animate_movement = 2
	flags = HEAR
	hud_possible = list(ANTAG_HUD)
	pressure_resistance = 8
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/internals = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/damageoverlay = null
	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null
	var/obj/screen/leap_icon = null
	var/obj/screen/healthdoll = null

	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/notransform = null	//Carbon
	var/hand = null
	var/eye_blind = 0		//Carbon
	var/eye_blurry = 0		//Carbon
	var/ear_deaf = 0		//Carbon
	var/ear_damage = 0		//Carbon
	var/stuttering = null	//Carbon
	var/slurring = 0		//Carbon
	var/real_name = null
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

	var/name_archive //For admin things like possession

	var/timeofdeath = 0//Living
	var/cpr_time = 1//Carbon


	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0//Carbon
	var/dizziness = 0//Carbon
	var/jitteriness = 0//Carbon
	var/nutrition = NUTRITION_LEVEL_FED + 50//Carbon
	var/satiety = 0//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0
	var/stunned = 0
	var/weakened = 0
	var/losebreath = 0//Carbon
	var/shakecamera = 0
	var/a_intent = "help"//Living
	var/m_intent = RUN//Living
	var/lastKnownIP = null
	var/atom/movable/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/storage/s_active = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human
	var/see_override = 0 //0 for no override, sets see_invisible = see_override in mob life process

	var/datum/hud/hud_used = null

	var/research_scanner = 0 //For research scanner equipped mobs. Enable to show research data when examining.
	var/datum/action/scan_mode/scanner = new

	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/music_lastplayed = "null"

	var/job = null//Living

	var/radiation = 0//Carbon

	var/voice_name = "unidentifiable voice"

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


	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?
	var/digitalinvis = 0 //Are they ivisible to the AI?
	var/image/digitaldisguise = null  //what does the AI see instead of them?

	var/weakeyes = 0 //Are they vulnerable to flashes?

	var/has_unlimited_silicon_privilege = 0 // Can they interact with station electronics

	var/force_compose = 0 //If this is nonzero, the mob will always compose it's own hear message instead of using the one given in the arguments.

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var
	var/atom/movable/remote_control //Calls relaymove() to whatever it is

	var/turf/listed_turf = null	//the current turf being examined in the stat panel

	var/list/permanent_huds = list()
	var/permanent_sight_flags = 0

	var/resize = 1 //Badminnery resize