/mob
	density = 1
	layer = 4.0
	animate_movement = 2
	flags = NOREACT
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	//Not in use yet
	var/obj/effect/organstructure/organStructure = null

//	var/uses_hud = 0
	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/mach = null
	var/obj/screen/sleep = null
	var/obj/screen/rest = null
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
	var/obj/screen/pain = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null

	var/emote_allowed = 1
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/already_placed = 0.0
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/poll_answer = 0.0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/next_move = null
	var/prev_move = null
	var/monkeyizing = null	//Carbon
	var/other = 0.0
	var/hand = null
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/slurring = null
	var/real_name = null
//	var/original_name = null //Original name is only used in ghost chat! Depracated, now used bb
	var/blinded = null
	var/bhunger = 0			//Carbon
	var/ajourn = 0
//	var/rejuv = null
	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/antitoxs = null
	var/plasma = null
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1
	var/eye_stat = null//Living, potentially Carbon
	var/lastpuke = 0
	var/unacidable = 0

	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living
	var/cpr_time = 1.0//Carbon


	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0//Carbon
	var/charges = 0.0
	var/nutrition = 400.0//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon
	var/intent = null//Living
	var/shakecamera = 0
	var/a_intent = "help"//Living
	var/m_int = null//Living
	var/m_intent = "run"//Living
	var/lastDblClick = 0
	var/lastKnownIP = null
	var/obj/structure/stool/bed/buckled = null//Living
	var/obj/item/handcuffed = null//Living
	var/obj/item/legcuffed = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/weapon/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human

	var/obj/hud/hud_used = null

	//var/list/organs = list(  ) //moved to human.
	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/inertia_dir = 0
	var/footstep = 1

	var/music_lastplayed = "null"

	var/job = null//Living

	var/nodamage = 0

	var/be_syndicate = 0//This really should be a client variable.
	var/be_random_name = 0
	var/const/blindness = 1//Carbon
	var/const/deafness = 2//Carbon
	var/const/muteness = 4//Carbon


	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/list/augmentations = list() //Carbon -- Doohl
	//see: setup.dm for list of augmentations

	var/voice_name = "unidentifiable voice"
	var/voice_message = null // When you are not understood by others (replaced with just screeches, hisses, chimpers etc.)
	var/say_message = null // When you are understood by others. Currently only used by aliens and monkeys in their say_quote procs

//Generic list for proc holders. Only way I can see to enable certain verbs/procs. Should be modified if needed.
	var/proc_holder_list[] = list()//Right now unused.
	//Also unlike the spell list, this would only store the object in contents, not an object in itself.

	/* Add this line to whatever stat module you need in order to use the proc holder list.
	Unlike the object spell system, it's also possible to attach verb procs from these objects to right-click menus.
	This requires creating a verb for the object proc holder.

	if (proc_holder_list.len)//Generic list for proc_holder objects.
		for(var/obj/effect/proc_holder/P in proc_holder_list)
			statpanel("[P.panel]","",P)
	*/

//The last mob/living/carbon to push/drag/grab this mob (mostly used by Metroids friend recognition)
	var/mob/living/carbon/LAssailant = null

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/obj/effect/proc_holder/spell/list/spell_list = list()

//Changlings, but can be used in other modes
	var/obj/effect/proc_holder/changpower/list/power_list = list()

//List of active diseases

	var/viruses = list() // replaces var/datum/disease/virus

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 1 //Set to 1 to trigger update_icons() at the next life() call

	var/UI = 'icons/mob/screen1_Midnight.dmi' // For changing the UI from preferences

	var/status_flags = 255	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)
	var/nopush = 0 //Can they be shoved?

	var/area/lastarea = null

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/datum/preferences/storedpreferences = null


	var/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open


	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/robot_talk_understand = 0
	var/alien_talk_understand = 0
	var/tajaran_talk_understand = 0
	var/soghun_talk_understand = 0
	var/skrell_talk_understand = 0
