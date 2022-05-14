/datum/round_event_control/scrubber_clog
	name = "Minor Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 20 //All weight values are very subject to change.
	max_occurrences = 3
	earliest_start = 5 MINUTES

/datum/round_event/scrubber_clog
	announceWhen = 1
	startWhen = 5
	var/obj/scrubber //Scrubber selected for the event
	var/mob/spawned_mob = /mob/living/basic/cockroach //What mob will be spawned
	var/severity = "Minor" //Severity of the event (how dangerous are the spawned mobs, and it what quantity)
	var/maximum_spawns //Cap on the number of spawned mobs that can be alive at once
	var/spawn_delay = 15 SECONDS //Interval between mob spawns

/datum/round_event/scrubber_clog/announce()
	priority_announce("[severity] biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area(scrubber)] area.", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()
	if(!scrubber)
		CRASH("Unable to find suitable scrubber.")
	spawned_mob = get_mob()
	maximum_spawns = rand(3, 5)

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list = list()
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded && !scrubber.clogged)
			scrubber_list += scrubber
	return pick(scrubber_list)

/datum/round_event/scrubber_clog/proc/get_mob() //picks from mob list of some sorts, use switches based on severity for which mob list to pick from
	var/mob/selected_mob
	switch(severity)
		if("Minor") //Spawns harmless nuisance mobs.
			var/list/minor_mobs = list(
				/mob/living/simple_animal/mouse,
				/mob/living/basic/cockroach
				)
			selected_mob = pick(minor_mobs)
			return selected_mob

		if("Major") //Spawns potentially dangerous mobs.
			var/list/major_mobs = list(
				/mob/living/simple_animal/hostile/rat,
				/mob/living/simple_animal/hostile/bee,
				/mob/living/simple_animal/hostile/giant_spider
				)
			selected_mob = pick(major_mobs)
			return selected_mob

		if("Critical") //Higher impact mobs, but with a lower max spawn.
			var/list/critical_mobs = list(
				/mob/living/simple_animal/hostile/retaliate/goose, //Janitors HATE geese.
				/mob/living/basic/cockroach/glockroach,
				/mob/living/simple_animal/hostile/carp,
				/mob/living/simple_animal/hostile/ooze,
				/mob/living/simple_animal/hostile/bee/toxin
				)
			selected_mob = pick(critical_mobs)
			return selected_mob


			//Maybe add a "strange" severity with very low weight, and would provide the crew with a more useful/goofier variety of mobs?


/datum/round_event/scrubber_clog/start()
	SEND_SIGNAL(scrubber, COMSIG_VENT_CLOG, spawned_mob, maximum_spawns, spawn_delay)

/datum/round_event_control/scrubber_clog/major
	name = "Major Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/major
	weight = 12 //Subject to change
	max_occurrences = 3
	earliest_start = 10 MINUTES

/datum/round_event/scrubber_clog/major
	severity = "Major"

/datum/round_event_control/scrubber_clog/critical
	name = "Critical Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/critical
	weight = 8 //Subject to change
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/scrubber_clog/critical
	severity = "Critical"
	maximum_spawns = 2

/datum/round_event/scrubber_clog/critical/announce()
	priority_announce("Potentially hazardous lifesigns detected in the [get_area(scrubber)] ventilation network.", "Security Alert")
