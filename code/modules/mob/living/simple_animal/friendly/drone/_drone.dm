
#define DRONE_HANDS_LAYER 1
#define DRONE_HEAD_LAYER 2
#define DRONE_TOTAL_LAYERS 2

/// Message displayed when new drone spawns in drone network
#define DRONE_NET_CONNECT "<span class='notice'>DRONE NETWORK: [name] connected.</span>"
/// Message displayed when drone in network dies
#define DRONE_NET_DISCONNECT "<span class='danger'>DRONE NETWORK: [name] is not responding.</span>"

/// Maintenance Drone icon_state (multiple colors)
#define MAINTDRONE	"drone_maint"
/// Repair Drone icon_state
#define REPAIRDRONE	"drone_repair"
/// Scout Drone icon_state
#define SCOUTDRONE	"drone_scout"
/// Clockwork Drone icon_state
#define CLOCKDRONE	"drone_clock"

/// [MAINTDRONE] hacked icon_state
#define MAINTDRONE_HACKED "drone_maint_red"
/// [REPAIRDRONE] hacked icon_state
#define REPAIRDRONE_HACKED "drone_repair_hacked"
/// [SCOUTDRONE] hacked icon_state
#define SCOUTDRONE_HACKED "drone_scout_hacked"

/**
 * # Maintenance Drone
 *
 * Small player controlled fixer-upper
 *
 * The maintenace drone is a ghost role with the objective to repair and
 * maintain the station.
 *
 * Featuring two dexterous hands, and a built in toolbox stocked with
 * tools.
 *
 * They have laws to prevent them from doing anything else.
 *
 */
/mob/living/simple_animal/drone
	name = "Drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_maint_grey"
	icon_living = "drone_maint_grey"
	icon_dead = "drone_maint_dead"
	health = 30
	maxHealth = 30
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 0
	wander = 0
	speed = 0
	ventcrawler = VENTCRAWLER_ALWAYS
	healable = 0
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = (CANPUSH | CANSTUN | CANKNOCKDOWN)
	gender = NEUTER
	mob_biotypes = MOB_ROBOTIC
	speak_emote = list("chirps")
	speech_span = SPAN_ROBOT
	bubble_icon = "machine"
	initial_language_holder = /datum/language_holder/drone
	mob_size = MOB_SIZE_SMALL
	has_unlimited_silicon_privilege = 1
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	hud_possible = list(DIAG_STAT_HUD, DIAG_HUD, ANTAG_HUD)
	unique_name = TRUE
	faction = list("neutral","silicon","turret")
	dextrous = TRUE
	dextrous_hud_type = /datum/hud/dextrous/drone
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 7
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_items = list(null, null)
	/// `TRUE` if we have picked our visual appearance, `FALSE` otherwise (default)
	var/picked = FALSE
	/// Stored drone color, restored when unhacked
	var/colour = "grey"
	var/list/drone_overlays[DRONE_TOTAL_LAYERS]
	/// Drone laws announced on spawn
	var/laws = \
	"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.\n"+\
	"2. You may not harm any being, regardless of intent or circumstance.\n"+\
	"3. Your goals are to actively build, maintain, repair, improve, and provide power to the best of your abilities within the facility that housed your activation." //for derelict drones so they don't go to station.
	/// Amount of damage sustained if hit by a heavy EMP pulse
	var/heavy_emp_damage = 25
	/// List of active alarms. See [/mob/living/simple_animal/drone/proc/triggerAlarm] and [/mob/living/simple_animal/drone/proc/cancelAlarm]
	var/alarms = list("Atmosphere" = list(), "Fire" = list(), "Power" = list())
	/// Internal storage slot. Fits any item
	var/obj/item/internal_storage
	/// Headwear slot
	var/obj/item/head
	/// Default [/mob/living/simple_animal/drone/var/internal_storage] item
	var/obj/item/default_storage = /obj/item/storage/backpack/duffelbag/drone
	/// Default [/mob/living/simple_animal/drone/var/head] item
	var/obj/item/default_hatmask
	/**
	  * icon_state of drone from icons/mobs/drone.dmi
	  *
	  * Possible states are:
	  *
	  * - [MAINTDRONE]
	  * - [REPAIRDRONE]
	  * - [SCOUTDRONE]
	  * - [CLOCKDRONE]
	  */
	var/visualAppearance = MAINTDRONE
	/// Hacked state, see [/mob/living/simple_animal/drone/proc/update_drone_hack]
	var/hacked = FALSE
	/// Flavor text announced to drones on [/mob/proc/Login]
	var/flavortext = \
	"\n<big><span class='warning'>DO NOT INTERFERE WITH THE ROUND AS A DRONE OR YOU WILL BE DRONE BANNED</span></big>\n"+\
	"<span class='notice'>Drones are a ghost role that are allowed to fix the station and build things. Interfering with the round as a drone is against the rules.</span>\n"+\
	"<span class='notice'>Actions that constitute interference include, but are not limited to:</span>\n"+\
	"<span class='notice'>     - Interacting with round critical objects (IDs, weapons, contraband, powersinks, bombs, etc.)</span>\n"+\
	"<span class='notice'>     - Interacting with living beings (communication, attacking, healing, etc.)</span>\n"+\
	"<span class='notice'>     - Interacting with non-living beings (dragging bodies, looting bodies, etc.)</span>\n"+\
	"<span class='warning'>These rules are at admin discretion and will be heavily enforced.</span>\n"+\
	"<span class='warning'><u>If you do not have the regular drone laws, follow your laws to the best of your ability.</u></span>"

/mob/living/simple_animal/drone/Initialize()
	. = ..()
	GLOB.drones_list += src
	access_card = new /obj/item/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

	if(default_storage)
		var/obj/item/I = new default_storage(src)
		equip_to_slot_or_del(I, ITEM_SLOT_DEX_STORAGE)
	if(default_hatmask)
		var/obj/item/I = new default_hatmask(src)
		equip_to_slot_or_del(I, ITEM_SLOT_HEAD)

	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

	alert_drones(DRONE_NET_CONNECT)

	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)

/mob/living/simple_animal/drone/med_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/drone/med_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	if(stat == DEAD)
		holder.icon_state = "huddead2"
	else if(incapacitated())
		holder.icon_state = "hudoffline"
	else
		holder.icon_state = "hudstat"

/mob/living/simple_animal/drone/Destroy()
	GLOB.drones_list -= src
	qdel(access_card) //Otherwise it ends up on the floor!
	return ..()

/mob/living/simple_animal/drone/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	check_laws()

	if(flavortext)
		to_chat(src, "[flavortext]")

	if(!picked)
		pickVisualAppearance()

/mob/living/simple_animal/drone/auto_deadmin_on_login()
	if(!client?.holder)
		return TRUE
	if(CONFIG_GET(flag/auto_deadmin_silicons) || (client.prefs?.toggles & DEADMIN_POSITION_SILICON))
		return client.holder.auto_deadmin()
	return ..()

/mob/living/simple_animal/drone/death(gibbed)
	..(gibbed)
	if(internal_storage)
		dropItemToGround(internal_storage)
	if(head)
		dropItemToGround(head)

	alert_drones(DRONE_NET_DISCONNECT)


/mob/living/simple_animal/drone/gib()
	dust()

/mob/living/simple_animal/drone/examine(mob/user)
	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <b>[src]</b>!")

	//Hands
	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "It has [I.get_examine_string(user)] in its [get_held_index_name(get_held_index_of_item(I))]."

	//Internal storage
	if(internal_storage && !(internal_storage.item_flags & ABSTRACT))
		. += "It is holding [internal_storage.get_examine_string(user)] in its internal storage."

	//Cosmetic hat - provides no function other than looks
	if(head && !(head.item_flags & ABSTRACT))
		. += "It is wearing [head.get_examine_string(user)] on its head."

	//Braindead
	if(!client && stat != DEAD)
		. += "Its status LED is blinking at a steady rate."

	//Hacked
	if(hacked)
		. += "<span class='warning'>Its display is glowing red!</span>"

	//Damaged
	if(health != maxHealth)
		if(health > maxHealth * 0.33) //Between maxHealth and about a third of maxHealth, between 30 and 10 for normal drones
			. += "<span class='warning'>Its screws are slightly loose.</span>"
		else //otherwise, below about 33%
			. += "<span class='boldwarning'>Its screws are very loose!</span>"

	//Dead
	if(stat == DEAD)
		if(client)
			. += "<span class='deadsay'>A message repeatedly flashes on its display: \"REBOOT -- REQUIRED\".</span>"
		else
			. += "<span class='deadsay'>A message repeatedly flashes on its display: \"ERROR -- OFFLINE\".</span>"
	. += "*---------*</span>"


/mob/living/simple_animal/drone/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) //Secbots won't hunt maintenance drones.
	return -10


/mob/living/simple_animal/drone/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	Stun(100)
	to_chat(src, "<span class='danger'><b>ER@%R: MME^RY CO#RU9T!</b> R&$b@0tin)...</span>")
	if(severity == 1)
		adjustBruteLoss(heavy_emp_damage)
		to_chat(src, "<span class='userdanger'>HeAV% DA%^MMA+G TO I/O CIR!%UUT!</span>")


/**
 * Alerts drones about different priorities of alarms
 *
 * Arguments:
 * * class - One of the keys listed in [/mob/living/simple_animal/drone/var/alarms]
 * * A - [/area] the alarm occurs
 * * O - unused argument, see [/mob/living/silicon/robot/triggerAlarm]
 * * alarmsource - [/atom] source of the alarm
 */
/mob/living/simple_animal/drone/proc/triggerAlarm(class, area/A, O, obj/alarmsource)
	if(alarmsource.z != z)
		return
	if(stat != DEAD)
		var/list/L = src.alarms[class]
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/sources = alarm[2]
				if (!(alarmsource in sources))
					sources += alarmsource
				return
		L[A.name] = list(A, list(alarmsource))
		to_chat(src, "--- [class] alarm detected in [A.name]!")

/**
 * Clears alarm and alerts drones
 *
 * Arguments:
 * * class - One of the keys listed in [/mob/living/simple_animal/drone/var/alarms]
 * * A - [/area] the alarm occurs
 * * alarmsource - [/atom] source of the alarm
 */
/mob/living/simple_animal/drone/proc/cancelAlarm(class, area/A, obj/origin)
	if(stat != DEAD)
		var/list/L = alarms[class]
		var/cleared = 0
		for (var/I in L)
			if (I == A.name)
				var/list/alarm = L[I]
				var/list/srcs  = alarm[2]
				if (origin in srcs)
					srcs -= origin
				if (srcs.len == 0)
					cleared = 1
					L -= I
		if(cleared)
			to_chat(src, "--- [class] alarm in [A.name] has been cleared.")

/mob/living/simple_animal/drone/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(affect_silicon)
		return ..()

/mob/living/simple_animal/drone/mob_negates_gravity()
	return TRUE

/mob/living/simple_animal/drone/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/simple_animal/drone/experience_pressure_difference(pressure_difference, direction)
	return

/mob/living/simple_animal/drone/bee_friendly()
	// Why would bees pay attention to drones?
	return TRUE

/mob/living/simple_animal/drone/electrocute_act(shock_damage, source, siemens_coeff, flags = NONE)
	return FALSE //So they don't die trying to fix wiring
