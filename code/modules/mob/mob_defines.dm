
/mob
	density = 1
	layer = 4.0
	animate_movement = 2

	w_type = RECYK_BIOLOGICAL

//	flags = NOREACT
	flags = HEAR | PROXMOVE
	var/datum/mind/mind

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/pullin = null
	var/obj/screen/kick_icon = null
	var/obj/screen/bite_icon = null
	var/obj/screen/visible = null
	var/obj/screen/purged = null
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
	var/obj/screen/gun/item/item_use_icon = null
	var/obj/screen/gun/move/gun_move_icon = null
	var/obj/screen/gun/run/gun_run_icon = null
	var/obj/screen/gun/mode/gun_setting_icon = null

	//monkey inventory icons
	var/obj/screen/m_suitclothes = null
	var/obj/screen/m_suitclothesbg = null
	var/obj/screen/m_hat = null
	var/obj/screen/m_hatbg = null
	var/obj/screen/m_glasses = null
	var/obj/screen/m_glassesbg = null

	//spells hud icons - this interacts with add_spell and remove_spell
	var/list/obj/screen/movable/spell_master/spell_masters = null

	//thou shall always be able to see the Geometer of Blood
	var/image/narsimage = null
	var/image/narglow = null

	//thou shall always be able to see the Bluespace Rift
	var/image/riftimage = null

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/obj/screen/zone_sel/zone_sel = null

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/attack_log = list( )
	var/already_placed = 0.0
	var/obj/machine
	var/other_mobs = null
	var/memory = ""
	var/poll_answer = 0.0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon
	var/atom/movable/pulling = null
	var/monkeyizing = null	//Carbon
	var/other = 0.0
	var/hand = null
	var/eye_blind = null	//Carbon
	var/eye_blurry = null	//Carbon
	var/ear_deaf = null		//Carbon
	var/ear_damage = null	//Carbon
	var/stuttering = null	//Carbon
	var/slurring = null		//Carbon
	var/real_name = null
	var/flavor_text = ""
	var/med_record = ""
	var/sec_record = ""
	var/gen_record = ""
	var/blinded = null
	var/bhunger = 0			//Carbon
	var/obj/effect/rune/ajourn
	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/antitoxs = null
	var/plasma = null
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/canmove = 1
	var/candrop = 1
	var/lastpuke = 0
	var/unacidable = 0

	var/size = SIZE_NORMAL
	//SIZE_TINY for tiny animals like mice and borers
	//SIZE_SMALL for monkeys dionae etc
	//SIZE_NORMAL for humans and most of the other mobs
	//SIZE_BIG for big guys
	//SIZE_HUGE for even bigger guys

	var/list/callOnFace = list()
	var/list/pinned = list()            // List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/abilities = list()         // For species-derived or admin-given powers.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/treadmill_speed = 1 //1 for most player things, simple animals get lower, xenos get higher

	var/name_archive //For admin things like possession

	var/timeofdeath = 0.0//Living
	var/cpr_time = 1.0//Carbon


	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0.0//Carbon
	var/dizziness = 0//Carbon
	var/jitteriness = 0//Carbon
	var/flying = 0
	var/charges = 0.0
	var/nutrition = 400.0//Carbon

	var/overeatduration = 0		// How long this guy is overeating //Carbon
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0//Carbon
	var/nobreath = 0.0//Carbon, but only used for humans so far
	var/intent = null//Living
	var/shakecamera = 0
	var/a_intent = I_HELP//Living
	var/m_int = null//Living
	var/m_intent = "run"//Living
	var/lastKnownIP = null
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/weapon/back = null//Human/Monkey
	var/obj/item/weapon/tank/internal = null//Human/Monkey
	var/obj/item/weapon/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/seer = 0 //for cult//Carbon, probably Human

	var/datum/hud/hud_used = null
	var/datum/ui_icons/gui_icons = null

	var/list/grabbed_by = list()
	var/list/requests = list()

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/inertia_dir = 0

	var/job = null//Living

	var/datum/dna/dna = null//Carbon
	var/radiation = 0.0//Carbon

	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later
	var/move_on_shuttle = 1 // Can move on the shuttle.
	var/captured = 0 //Functionally, should give the same effect as being buckled into a chair when true.

	var/movement_speed_modifier = 1

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

//The last mob/living/carbon to push/drag/grab this mob (mostly used by slimes friend recognition)
	var/mob/living/carbon/LAssailant = null

//Wizard mode, but can be used in other modes thanks to the brand new "Give Spell" badmin button
	var/spell/list/spell_list = list()

//Changlings, but can be used in other modes
//	var/obj/effect/proc_holder/changpower/list/power_list = list()

//List of active diseases

	var/viruses = list() // replaces var/datum/disease/virus

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 1 //Set to 1 to trigger update_icons() at the next life() call

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/list/radar_blips = list() // list of screen objects, radar blips
	var/radar_open = 0 	// nonzero is radar is open

	var/force_compose = 0 //If this is nonzero, the mob will always compose it's own hear message instead of using the one given in the arguments.



	var/obj/control_object = null	//Used by admins to possess objects. All mobs should have this var

	var/obj/orient_object = null	//Similar to control object. But only lets the mob manipulate which direction the object is facing.

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak
	/*var/robot_talk_understand = 0
	var/alien_talk_understand = 0*/

	var/has_limbs = 1 //Whether this mob have any limbs he can move with
	var/can_stand = 1 //Whether this mob have ability to stand

	var/immune_to_ssd = 0

	var/turf/listed_turf = null  //the current turf being examined in the stat panel

	var/list/active_genes=list()

	var/kills=0

	var/last_movement = -100 // Last world.time the mob actually moved of its own accord.

	// /vg/ - Prevent mobs from being moved by a client.
	var/deny_client_move = 0
	var/incorporeal_move = INCORPOREAL_DEACTIVATE

	//Keeps track of where the mob was spawned. Mostly for teleportation purposes. and no, using initial() doesn't work.
	var/origin_x = 0
	var/origin_y = 0
	var/origin_z = 0

	var/iscorpse = 0 //Keeps track of whether this was spawned from a landmark or not.

	penetration_dampening = 7

	var/list/languages[0]
	var/stat_fucked = 1
	var/event/on_uattack
	var/event/on_logout
	forceinvertredraw = 1

	var/list/alphas = list()
	var/spell_channeling

/mob/resetVariables()
	..("callOnFace", "pinned", "embedded", "abilities", "grabbed_by", "requests", "mapobjs", "mutations", "spell_list", "viruses", "resistances", "radar_blips", "active_genes", "attack_log", "speak_emote", args)
	callOnFace = list()
	pinned = list()
	embedded = list()
	abilities = list()
	grabbed_by = list()
	requests = list()
	mapobjs = list()
	mutations = list()
	spell_list = list()
	viruses = list()
	resistances = list()
	radar_blips = list()
	active_genes = list()
	attack_log = list()
