#define MOB_SPAWN_MINIMUM 3

/datum/round_event_control/vent_clog
	name = "Ventilation Clog: Minor"
	typepath = /datum/round_event/vent_clog
	weight = 25
	earliest_start = 5 MINUTES
	category = EVENT_CATEGORY_JANITORIAL
	description = "Harmless mobs climb out of a vent."

/datum/round_event_control/vent_clog/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		var/turf/vent_turf = get_turf(vent)
		var/area/vent_area = get_area(vent)
		if(vent_turf && is_station_level(vent_turf.z) && !vent.welded && istype(vent_area, /area/station))
			return TRUE //make sure we have a valid vent to spawn from.
	return FALSE

/datum/round_event/vent_clog
	announce_when = 10
	announce_chance = 90
	end_when = 600

	///Vent selected for the event.
	var/obj/machinery/atmospherics/components/unary/vent_pump/vent
	///What mob will be spawned
	var/mob/spawned_mob = /mob/living/basic/cockroach
	///Cap on the number of spawned mobs that can be alive at once.
	var/maximum_spawns = MOB_SPAWN_MINIMUM
	///Interval between mob spawns.
	var/spawn_delay = 10
	///Used to track/limit produced mobs.
	var/list/living_mobs = list()
	///The list of decals we will choose from to spawn when producing a mob
	var/list/filth_spawn_types = list()

/datum/round_event/vent_clog/announce(fake)
	var/area/event_area = fake ? pick(GLOB.teleportlocs) : get_area_name(vent)
	priority_announce("Minor biological obstruction detected in the ventilation network. Blockage is believed to be in the [event_area].", "Custodial Notification")

/datum/round_event/vent_clog/setup()
	vent = get_vent()
	spawned_mob = get_mob()
	end_when = rand(300, 600)
	maximum_spawns = rand(MOB_SPAWN_MINIMUM, 10)
	spawn_delay = rand(10, 15)
	filth_spawn_types = list(
		/obj/effect/decal/cleanable/vomit,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/blood/oil,
	)

/datum/round_event/vent_clog/start()
	clog_vent()
	announce_to_ghosts(vent)

/datum/round_event/vent_clog/tick() //Checks if spawn_interval is met, then sends signal to vent to produce a mob.
	if(activeFor % spawn_delay == 0)
		life_check()
		if(living_mobs.len < maximum_spawns)
			produce_mob()

/datum/round_event/vent_clog/end() //No end announcement. If you want to take the easy way out and just leave the vent welded, you must open it at your own peril.
	vent = null
	living_mobs.Cut()

/**
 * Selects which mob will be spawned for a given vent clog event.
 *
 * Creates a static list of mobs, which is different based on the severity of the event being run, and returns a pick() of it.
 */

/datum/round_event/vent_clog/proc/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
		/mob/living/basic/cockroach/bloodroach,
		/mob/living/basic/spider/maintenance,
		/mob/living/basic/mouse,
		/mob/living/basic/snail,
	)
	return pick(mob_list)

/**
 * Finds a valid vent to spawn mobs from.
 *
 * Randomly selects a vent that is on-station, unwelded, and hosted by a passable turf. If no vents are found, the event
 * is immediately killed.
 */

/datum/round_event/vent_clog/proc/get_vent()
	var/list/vent_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_pump/vent as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/atmospherics/components/unary/vent_pump))
		var/turf/vent_turf = get_turf(vent)
		var/area/vent_area = get_area(vent)
		if(vent_turf && is_station_level(vent_turf.z) && !vent.welded && istype(vent_area, /area/station) && !vent_turf.is_blocked_turf_ignore_climbable())
			vent_list += vent

	if(!length(vent_list))
		kill()
		CRASH("Unable to find suitable vent.")

	return pick(vent_list)

/**
 * Checks which mobs in the mob spawn list are alive.
 *
 * Checks each mob in the living_mobs list, to see if they're dead or not. If dead, they're removed from the list.
 * This is used to keep new mobs spawning as the old ones die.
 */

/datum/round_event/vent_clog/proc/life_check()
	for(var/datum/weakref/mob_ref as anything in living_mobs)
		var/mob/living/real_mob = mob_ref.resolve()
		if(QDELETED(real_mob) || real_mob.stat == DEAD)
			living_mobs -= mob_ref

/**
 * Finds a new vent for the event if the original is destroyed.
 *
 * This is used when the vent for the event is destroyed. It picks a new vent and announces that the event has moved elsewhere.
 * Handles the vent ref if there are no valid vents to replace it with.
 */

/datum/round_event/vent_clog/proc/vent_move(datum/source)
	SIGNAL_HANDLER
	vent = null //If by some great calamity, the last valid vent is destroyed, the ref is cleared.
	vent = get_vent()

	clog_vent()

	announce_to_ghosts(vent)
	priority_announce("Lifesign readings have moved to a new location in the ventilation network. New Location: [prob(50) ? "Unknown.":"[get_area_name(vent)]."]", "Lifesign Notification")

/**
 * Handles the production of our mob and adds it to our living_mobs list
 *
 * Used by the vent clog random event to handle the spawning of mobs. The proc receives the mob that will be spawned,
 * and the event's current list of living mobs produced by the event so far. After checking if the vent is welded, the
 * new mob is created on the vent's turf, then added to the living_mobs list.
 */

/datum/round_event/vent_clog/proc/produce_mob()
	var/turf/vent_loc = get_turf(vent)
	if (isnull(vent_loc))
		CRASH("[vent] has no loc, aborting mobspawn")

	if(vent.welded || vent_loc.is_blocked_turf_ignore_climbable()) // vents under tables can still spawn stuff
		return

	var/mob/new_mob = new spawned_mob(vent_loc) // we spawn it early so we can actually use is_blocked_turf
	living_mobs += WEAKREF(new_mob)
	vent.visible_message(span_warning("[new_mob] crawls out of [vent]!"))

	var/list/potential_locations = list(vent_loc) // already confirmed to be accessable via the 2nd if check of the proc

	// exists to prevent mobs from trying to move onto turfs they physically cannot
	for(var/turf/nearby_turf in oview(1, get_turf(vent))) // oview, since we always add our loc to the list
		if(!nearby_turf.is_blocked_turf(source_atom = new_mob))
			potential_locations += nearby_turf

	var/turf/spawn_location = pick(potential_locations)
	new_mob.Move(spawn_location)

	var/filth_to_spawn = pick(filth_spawn_types)
	new filth_to_spawn(spawn_location)
	playsound(spawn_location, 'sound/effects/splat.ogg', 30, TRUE)

///Signal catcher for plunger_act()
/datum/round_event/vent_clog/proc/plunger_unclog(datum/source, obj/item/plunger/attacking_plunger, mob/user, reinforced)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_unclog), user)
	return COMPONENT_NO_AFTERATTACK

///Handles the actual unclogging action and ends the event on completion.
/datum/round_event/vent_clog/proc/attempt_unclog(mob/user)
	if(vent.welded)
		to_chat(user, span_notice("You cannot pump [vent] if it's welded shut!"))
		return

	user.balloon_alert_to_viewers("plunging vent...", "plunging clogged vent...")
	if(do_after(user, 6 SECONDS, target = vent))
		user.balloon_alert_to_viewers("finished plunging")
		clear_signals()
		kill()

///Handles the initial steps of clogging a vent, either at event start or when the vent moves.
/datum/round_event/vent_clog/proc/clog_vent()
	RegisterSignal(vent, COMSIG_QDELETING, PROC_REF(vent_move))
	RegisterSignal(vent, COMSIG_PLUNGER_ACT, PROC_REF(plunger_unclog))

	for(var/turf/nearby_turf in view(2, get_turf(vent)))
		if(isopenturf(nearby_turf) && prob(85))
			new /obj/effect/decal/cleanable/dirt(nearby_turf)

	produce_mob()

///Clears the signals related to the event, before we wrap things up.
/datum/round_event/vent_clog/proc/clear_signals()
	UnregisterSignal(vent, list(COMSIG_QDELETING, COMSIG_PLUNGER_ACT))

/datum/round_event_control/vent_clog/major
	name = "Ventilation Clog: Major"
	typepath = /datum/round_event/vent_clog/major
	weight = 12
	max_occurrences = 5
	earliest_start = 10 MINUTES
	description = "Dangerous mobs climb out of a vent."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4

/datum/round_event/vent_clog/major/setup()
	. = ..()
	maximum_spawns = rand(MOB_SPAWN_MINIMUM, 5)
	spawn_delay = rand(15,20)
	filth_spawn_types = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/insectguts,
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/blood/oil,
	)

/datum/round_event/vent_clog/major/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/bee,
		/mob/living/basic/cockroach/hauberoach,
		/mob/living/basic/spider/giant,
		/mob/living/basic/mouse/rat,
	)
	return pick(mob_list)

/datum/round_event/vent_clog/major/announce(fake)
	var/area/event_area = fake ? pick(GLOB.teleportlocs) : get_area_name(vent)
	priority_announce("Major biological obstruction detected in the ventilation network. Blockage is believed to be in the [event_area] area.", "Infestation Alert")

/datum/round_event_control/vent_clog/critical
	name = "Ventilation Clog: Critical"
	typepath = /datum/round_event/vent_clog/critical
	weight = 8
	min_players = 15
	max_occurrences = 3
	earliest_start = 25 MINUTES
	description = "Really dangerous mobs climb out of a vent."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 6

/datum/round_event/vent_clog/critical/setup()
	. = ..()
	spawn_delay = rand(15,25)
	maximum_spawns = rand(MOB_SPAWN_MINIMUM, 6)
	filth_spawn_types = list(
		/obj/effect/decal/cleanable/blood,
		/obj/effect/decal/cleanable/blood/splatter,
	)

/datum/round_event/vent_clog/critical/announce(fake)
	var/area/event_area = fake ? pick(GLOB.teleportlocs) : get_area_name(vent)
	priority_announce("Potentially hazardous lifesigns detected in the [event_area] ventilation network.", "Security Alert")

/datum/round_event/vent_clog/critical/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/bee/toxin,
		/mob/living/basic/carp,
		/mob/living/basic/cockroach/glockroach,
	)
	return pick(mob_list)

/datum/round_event_control/vent_clog/strange
	name = "Ventilation Clog: Strange"
	typepath = /datum/round_event/vent_clog/strange
	weight = 5
	max_occurrences = 2
	description = "Strange mobs climb out of a vent, harmfulness varies."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 7

/datum/round_event/vent_clog/strange/setup()
	. = ..()
	end_when = rand(600, 900)
	spawn_delay = rand(6, 25)
	maximum_spawns = rand(MOB_SPAWN_MINIMUM, 10)
	filth_spawn_types = list(
		/obj/effect/decal/cleanable/blood/xeno,
		/obj/effect/decal/cleanable/fuel_pool,
		/obj/effect/decal/cleanable/greenglow,
		/obj/effect/decal/cleanable/vomit,
	)

/datum/round_event/vent_clog/strange/announce(fake)
	var/area/event_area = fake ? pick(GLOB.teleportlocs) : get_area_name(vent)
	priority_announce("Unusual lifesign readings detected in the [event_area] ventilation network.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/vent_clog/strange/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/bear,
		/mob/living/basic/cockroach/glockroach/mobroach,
		/mob/living/basic/goose,
		/mob/living/basic/lightgeist,
		/mob/living/basic/mothroach,
		/mob/living/basic/mushroom,
		/mob/living/basic/viscerator,
		/mob/living/basic/pet/gondola,
	)
	return pick(mob_list)

#undef MOB_SPAWN_MINIMUM
