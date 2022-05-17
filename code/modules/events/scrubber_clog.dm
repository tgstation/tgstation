/datum/round_event_control/scrubber_clog
	name = "Minor Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 25
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/scrubber_clog
	announceWhen = 1 SECONDS
	startWhen = 10 SECONDS
	endWhen = 10 MINUTES

	///Scrubber selected for the event.
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber
	///What mob will be spawned
	var/mob/spawned_mob = /mob/living/basic/cockroach
	///Severity of the event (how dangerous are the spawned mobs, and at what quantity).
	var/severity = "Minor"
	///Cap on the number of spawned mobs that can be alive at once.
	var/maximum_spawns = 3
	///Interval between mob spawns.
	var/spawn_delay = 10 SECONDS
	///Used to track/limit produced mobs.
	var/list/living_mobs = list()
	///Used for tracking if the clog signal should be sent.
	var/clogged = TRUE

/datum/round_event/scrubber_clog/announce()
	priority_announce("[severity] biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area(scrubber)] area.", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()
	if(!scrubber)
		CRASH("Unable to find suitable scrubber.")
	spawned_mob = get_mob()
	endWhen = rand(5 MINUTES , 10 MINUTES)
	maximum_spawns = rand(3, 5)
	spawn_delay = rand(10 SECONDS, 15 SECONDS)

/**
 * Finds a valid scrubber for the scrubber clog event.
 *
 * For evert scrubber in the round, checks if the scrubber turf is on-station, and is neither welded nor already clogged, and
 * adds it to a list. A random scrubber is picked from this list, and returned as the scrubber that will be used for the event.
 */

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded && !scrubber.clogged)
			scrubber_list += scrubber
	return pick(scrubber_list)

/**
 * Selects which mob will be spawned for a given scrubber clog event.
 *
 * Using a switch, this proc checks for the severity of the scrubber clog event, and will generate a pool of mobs based on the severity.
 * It will then pick from the list to determine the mob that will be spawned for the event.
 */

/datum/round_event/scrubber_clog/proc/get_mob()
	switch(severity)
		if("Minor") //Spawns completely harmless nuisance mobs.
			var/list/minor_mobs = list(
				/mob/living/simple_animal/mouse,
				/mob/living/basic/cockroach,
				/mob/living/simple_animal/butterfly
				)
			return pick(minor_mobs)

		if("Major") //Spawns potentially dangerous mobs.
			var/list/major_mobs = list(
				/mob/living/simple_animal/hostile/rat,
				/mob/living/simple_animal/hostile/bee,
				/mob/living/simple_animal/hostile/giant_spider
				)
			return pick(major_mobs)

		if("Critical") //Higher impact mobs, but with a lower max spawn.
			var/list/critical_mobs = list(
				/mob/living/simple_animal/hostile/carp,
				/mob/living/simple_animal/hostile/bee/toxin,
				/mob/living/basic/cockroach/glockroach,
				)
			return pick(critical_mobs)

		if("Strange") //Useful or silly mobs. Still hazardous. Very low weight.
			var/list/strange_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/goose, //Janitors HATE geese.
				/mob/living/simple_animal/hostile/bear,
				/mob/living/simple_animal/pet/gondola,
				/mob/living/simple_animal/hostile/mushroom,
				/mob/living/simple_animal/hostile/lightgeist
				)
			return pick(strange_mobs)

/datum/round_event/scrubber_clog/start() //Sets the scrubber up for unclogging/mob production.
	scrubber.clog()
	scrubber.produce_mob() //The first one's free!

/datum/round_event/scrubber_clog/tick() //Checks if spawn_interval is met, then sends signal to scrubber to produce a mob.
	if(activeFor % spawn_delay == 0 && scrubber.clogged == TRUE)
		life_check()
		if(living_mobs.len < maximum_spawns && clogged)
			scrubber.produce_mob(spawned_mob, living_mobs)

/datum/round_event/scrubber_clog/end() //No end announcement. If you want to take the easy way out and just leave the vent welded, you must open it at your own peril.
	scrubber.unclog()

/**
 * Checks which mobs in the mob spawn list are alive.
 *
 * Checks each mob in the living_mobs list, to see if they're dead or not. If dead, they're removed from the list.
 * This is used to keep new mobs spawning as the old ones die.
 */

/datum/round_event/scrubber_clog/proc/life_check()
	for(var/mob/living/mob_check in living_mobs)
		if(mob_check.health <= 0)
			living_mobs -= mob_check

/datum/round_event_control/scrubber_clog/major
	name = "Major Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/major
	weight = 12
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/scrubber_clog/major
	severity = "Major"

/datum/round_event/scrubber_clog/major/setup()
	. = ..()
	maximum_spawns = rand(2,4)
	spawn_delay = rand(15 SECONDS, 20 SECONDS)

/datum/round_event_control/scrubber_clog/critical
	name = "Critical Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/critical
	weight = 8
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/scrubber_clog/critical
	severity = "Critical"
	maximum_spawns = 3

/datum/round_event/scrubber_clog/critical/setup()
	. = ..()
	spawn_delay = rand(15 SECONDS, 25 SECONDS)

/datum/round_event/scrubber_clog/critical/announce()
	priority_announce("Potentially hazardous lifesigns detected in the [get_area(scrubber)] ventilation network.", "Security Alert")

/datum/round_event_control/scrubber_clog/strange
	name = "Strange Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/strange
	weight = 5
	max_occurrences = 1

/datum/round_event/scrubber_clog/strange
	severity = "Strange"
	maximum_spawns = 3

/datum/round_event/scrubber_clog/strange/setup()
	. = ..()
	endWhen = rand(10 MINUTES, 12 MINUTES)
	spawn_delay = rand(6 SECONDS, 25 SECONDS) //Wide range, for maximum utility/comedy

/datum/round_event/scrubber_clog/strange/announce()
	priority_announce("Unusual lifesign readings detected in the [get_area(scrubber)] ventilation network.", "Lifesign Alert", ANNOUNCER_ALIENS)
