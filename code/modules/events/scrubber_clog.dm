/datum/round_event_control/scrubber_clog
	name = "Scrubber Clog: Minor"
	typepath = /datum/round_event/scrubber_clog
	weight = 25
	max_occurrences = 3
	earliest_start = 5 MINUTES
	category = EVENT_CATEGORY_JANITORIAL
	description = "Harmless mobs climb out of a scrubber."

/datum/round_event_control/scrubber_clog/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded)
			return TRUE //make sure we have a valid scrubber to spawn from.
	return FALSE

/datum/round_event/scrubber_clog
	announce_when = 10
	end_when = 600

	///Scrubber selected for the event.
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber
	///What mob will be spawned
	var/mob/spawned_mob = /mob/living/basic/cockroach
	///Cap on the number of spawned mobs that can be alive at once.
	var/maximum_spawns = 3
	///Interval between mob spawns.
	var/spawn_delay = 10
	///Used to track/limit produced mobs.
	var/list/living_mobs = list()

/datum/round_event/scrubber_clog/announce()
	priority_announce("Minor biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area_name(scrubber)].", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()

	apply_signals()

	spawned_mob = get_mob()
	end_when = rand(300, 600)
	maximum_spawns = rand(3, 5)
	spawn_delay = rand(10, 15)

/datum/round_event/scrubber_clog/start() //Sets the scrubber up for unclogging/mob production.
	produce_mob() //The first one's free!
	announce_to_ghosts(scrubber)

/datum/round_event/scrubber_clog/tick() //Checks if spawn_interval is met, then sends signal to scrubber to produce a mob.
	if(activeFor % spawn_delay == 0)
		life_check()
		if(living_mobs.len < maximum_spawns)
			produce_mob()

/datum/round_event/scrubber_clog/end() //No end announcement. If you want to take the easy way out and just leave the vent welded, you must open it at your own peril.
	scrubber = null
	living_mobs.Cut()

/**
 * Selects which mob will be spawned for a given scrubber clog event.
 *
 * Creates a static list of mobs, which is different based on the severity of the event being run, and returns a pick() of it.
 */

/datum/round_event/scrubber_clog/proc/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/butterfly,
		/mob/living/basic/cockroach,
		/mob/living/basic/giant_spider/maintenance,
		/mob/living/basic/mouse,
	)
	return pick(mob_list)

/**
 * Finds a valid scrubber to spawn mobs from.
 *
 * Randomly selects a scrubber that is on-station and unwelded. If no scrubbers are found, the event
 * is immediately killed.
 */

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded)
			scrubber_list += scrubber

	if(!length(scrubber_list))
		kill()
		CRASH("Unable to find suitable scrubber.")

	return pick(scrubber_list)

/**
 * Checks which mobs in the mob spawn list are alive.
 *
 * Checks each mob in the living_mobs list, to see if they're dead or not. If dead, they're removed from the list.
 * This is used to keep new mobs spawning as the old ones die.
 */

/datum/round_event/scrubber_clog/proc/life_check()
	for(var/datum/weakref/mob_ref as anything in living_mobs)
		var/mob/living/real_mob = mob_ref.resolve()
		if(QDELETED(real_mob) || real_mob.stat == DEAD)
			living_mobs -= mob_ref

/**
 * Finds a new scrubber for the event if the original is destroyed.
 *
 * This is used when the scrubber for the event is destroyed. It picks a new scrubber and announces that the event has moved elsewhere.
 * Handles the scrubber ref if there are no valid scrubbers to replace it with.
 */

/datum/round_event/scrubber_clog/proc/scrubber_move(datum/source)
	SIGNAL_HANDLER
	scrubber = null //If by some great calamity, the last valid scrubber is destroyed, the ref is cleared.
	scrubber = get_scrubber()

	apply_signals()
	produce_mob()

	announce_to_ghosts(scrubber)
	priority_announce("Lifesign readings have moved to a new location in the ventilation network. New Location: [prob(50) ? "Unknown.":"[get_area_name(scrubber)]."]", "Lifesign Notification")

/**
 * Handles the production of our mob and adds it to our living_mobs list
 *
 * Used by the scrubber clog random event to handle the spawning of mobs. The proc recieves the mob that will be spawned,
 * and the event's current list of living mobs produced by the event so far. After checking if the vent is welded, the
 * new mob is created on the scrubber's turf, then added to the living_mobs list.
 */

/datum/round_event/scrubber_clog/proc/produce_mob()
	if(scrubber.welded)
		return

	var/mob/new_mob = new spawned_mob(get_turf(scrubber))
	living_mobs += WEAKREF(new_mob)
	scrubber.visible_message(span_warning("[new_mob] crawls out of [scrubber]!"))

///Signal catcher for plunger_act()
/datum/round_event/scrubber_clog/proc/plunger_unclog(datum/source, obj/item/plunger/P, mob/user, reinforced)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(attempt_unclog), user)

/datum/round_event/scrubber_clog/proc/attempt_unclog(mob/user)
	if(scrubber.welded)
		to_chat(user, span_notice("You cannot pump [scrubber] if it's welded shut!"))
		return

	to_chat(user, span_notice("You begin pumping [scrubber] with your plunger."))
	if(do_after(user, 6 SECONDS, target = scrubber))
		to_chat(user, span_notice("You finish pumping [scrubber]."))
		end_when = activeFor + 1 //Skip to the end and wrap things up

/datum/round_event/scrubber_clog/proc/apply_signals()
	RegisterSignal(scrubber, COMSIG_PARENT_QDELETING, PROC_REF(scrubber_move))
	RegisterSignal(scrubber, COMSIG_PLUNGER_ACT, PROC_REF(plunger_unclog))

/datum/round_event_control/scrubber_clog/major
	name = "Scrubber Clog: Major"
	typepath = /datum/round_event/scrubber_clog/major
	weight = 12
	max_occurrences = 3
	earliest_start = 10 MINUTES
	description = "Dangerous mobs climb out of a scrubber."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4

/datum/round_event/scrubber_clog/major/setup()
	. = ..()
	maximum_spawns = rand(2,4)
	spawn_delay = rand(15,20)

/datum/round_event/scrubber_clog/major/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/mouse/rat,
		/mob/living/simple_animal/hostile/bee,
		/mob/living/basic/giant_spider,
	)
	return pick(mob_list)

/datum/round_event/scrubber_clog/major/announce()
	priority_announce("Major biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area_name(scrubber)] area.", "Infestation Alert")

/datum/round_event_control/scrubber_clog/critical
	name = "Scrubber Clog: Critical"
	typepath = /datum/round_event/scrubber_clog/critical
	weight = 8
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES
	description = "Really dangerous mobs climb out of a scrubber."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 6

/datum/round_event/scrubber_clog/critical
	maximum_spawns = 3

/datum/round_event/scrubber_clog/critical/setup()
	. = ..()
	spawn_delay = rand(15,25)

/datum/round_event/scrubber_clog/critical/announce()
	priority_announce("Potentially hazardous lifesigns detected in the [get_area_name(scrubber)] ventilation network.", "Security Alert")

/datum/round_event/scrubber_clog/critical/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/carp,
		/mob/living/simple_animal/hostile/bee/toxin,
		/mob/living/basic/cockroach/glockroach,
	)
	return pick(mob_list)

/datum/round_event_control/scrubber_clog/strange
	name = "Scrubber Clog: Strange"
	typepath = /datum/round_event/scrubber_clog/strange
	weight = 5
	max_occurrences = 1
	description = "Strange mobs climb out of a scrubber, harmfulness varies."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 7

/datum/round_event/scrubber_clog/strange
	maximum_spawns = 3

/datum/round_event/scrubber_clog/strange/setup()
	. = ..()
	end_when = rand(600, 720)
	spawn_delay = rand(6, 25) //Wide range, for maximum utility/comedy

/datum/round_event/scrubber_clog/strange/announce()
	priority_announce("Unusual lifesign readings detected in the [get_area_name(scrubber)] ventilation network.", "Lifesign Alert", ANNOUNCER_ALIENS)

/datum/round_event/scrubber_clog/strange/get_mob()
	var/static/list/mob_list = list(
		/mob/living/basic/lightgeist,
		/mob/living/simple_animal/hostile/bear,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/retaliate/goose, //Janitors HATE geese.
		/mob/living/simple_animal/pet/gondola,
	)
	return pick(mob_list)
