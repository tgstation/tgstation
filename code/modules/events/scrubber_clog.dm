/datum/round_event_control/scrubber_clog
	name = "Minor Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 25 //All weight values are very subject to change.
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/scrubber_clog
	announceWhen = 1
	startWhen = 10
	endWhen = 6000 //Maybe add a negative result in end() to prevent people from just ignoring the event?
	var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber //Scrubber selected for the event
	var/mob/spawned_mob = /mob/living/basic/cockroach //What mob will be spawned
	var/severity = "Minor" //Severity of the event (how dangerous are the spawned mobs, and at what quantity)
	var/maximum_spawns = 3 //Cap on the number of spawned mobs that can be alive at once
	var/spawn_delay = 10 //Interval between mob spawns
	var/list/living_mobs = list() //Used to track/limit produced mobs
	var/clogged = TRUE //Used for tracking if the clog signal should be sent

/datum/round_event/scrubber_clog/announce()
	priority_announce("[severity] biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area(scrubber)] area.", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()
	if(!scrubber)
		CRASH("Unable to find suitable scrubber.")
	spawned_mob = get_mob()
	maximum_spawns = rand(3, 5)
	spawn_delay = rand(10,15)

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded && !scrubber.clogged)
			scrubber_list += scrubber
	return pick(scrubber_list)

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

/datum/round_event/scrubber_clog/start() //Sets the scrubber up for unclogging/mob production
	SEND_SIGNAL(scrubber, COMSIG_VENT_CLOG)
	SEND_SIGNAL(scrubber, COMSIG_PRODUCE_MOB, spawned_mob, living_mobs) //The first one's free!

/datum/round_event/scrubber_clog/tick() //Checks if spawn_interval is met, then sends signal to scrubber to produce a mob
	if(activeFor % spawn_delay == 0 && scrubber.is_clogged() == TRUE)
		life_check()
		if(living_mobs.len < maximum_spawns && clogged)
			SEND_SIGNAL(scrubber, COMSIG_PRODUCE_MOB, spawned_mob, living_mobs)

/datum/round_event/scrubber_clog/proc/life_check()
	for(var/mob/living/mob_check in living_mobs)
		if(mob_check.health <= 0 || !mob_check.health)
			living_mobs -= mob_check

/datum/round_event_control/scrubber_clog/major
	name = "Major Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/major
	weight = 12 //Subject to change
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/scrubber_clog/major
	severity = "Major"

/datum/round_event/scrubber_clog/major/setup()
	. = ..()
	maximum_spawns = rand(2,4)
	spawn_delay = rand(15,20)

/datum/round_event_control/scrubber_clog/critical
	name = "Critical Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/critical
	weight = 8 //Subject to change
	min_players = 15
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/scrubber_clog/critical
	severity = "Critical"

/datum/round_event/scrubber_clog/critical/setup()
	. = ..()
	maximum_spawns = 3
	spawn_delay = rand(15, 25)

/datum/round_event/scrubber_clog/critical/announce()
	priority_announce("Potentially hazardous lifesigns detected in the [get_area(scrubber)] ventilation network.", "Security Alert")

/datum/round_event_control/scrubber_clog/strange
	name = "Strange Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/strange
	weight = 5 //Subject to change
	max_occurrences = 1

/datum/round_event/scrubber_clog/strange
	severity = "Strange"

/datum/round_event/scrubber_clog/critical/setup()
	. = ..()
	maximum_spawns = 3
	spawn_delay = rand(10, 25) //Wide range, for maximum utility/comedy

/datum/round_event/scrubber_clog/strange/announce()
	priority_announce("Unusual lifesign readings detected in the [get_area(scrubber)] ventilation network.", "Lifesign Alert")
