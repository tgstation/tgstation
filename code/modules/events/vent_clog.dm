/datum/round_event_control/scrubber_clog
	name = "Minor Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 15 //All weight values are very subject to change.
	max_occurrences = 3

/datum/round_event/scrubber_clog
	announceWhen = 1
	startWhen = 10
	var/scrubber //Scrubber selected for the event
	var/spawned_mob = /mob/living/basic/cockroach //What mob will spawn out of the vents
	var/severity = "Minor" //Severity of the event (how dangerous are the spawned mobs, and it what quantity)
	var/maximum_spawns //Cap on the number of spawned mobs that can be alive at once

/datum/round_event/scrubber_clog/announce()
	priority_announce("[severity] biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area(scrubber)] area.", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()
	if(!scrubber)
		CRASH("Unable to find suitable scrubber.")
	spawned_mob = get_mob()
	maximum_spawns = rand(3, 5)

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded)
			scrubber_list += scrubber
	return pick(scrubber_list)

/datum/round_event/scrubber_clog/proc/get_mob() //picks from mob list of some sorts, use switches based on severity for which mob list to pick from
	switch(severity)
		if("Minor") //Spawns nuisance mobs that are small enough to realistically clog a vent.
			var/list/minor_mobs = list(
				/mob/living/simple_animal/mouse,
				/mob/living/basic/cockroach,
				/mob/living/basic/stickman/dog)
			return pick(minor_mobs)

		if("Major") //Spawns larger or more potentially dangerous mobs.
			var/list/major_mobs = list(
				/mob/living/simple_animal/hostile/rat,
				/mob/living/basic/cockroach,
				/mob/living/basic/stickman/dog)
			return pick(major_mobs)

		if("Critical") //Higher impact mobs, but with a lower max spawn
			var/list/critical_mobs = list(
				/mob/living/simple_animal/hostile/giant_spider,
				/mob/living/simple_animal/hostile/retaliate/goose, //Janitors HATE geese.
				/mob/living/basic/cockroach/glockroach,
				/mob/living/simple_animal/hostile/ooze
				)
			return pick(critical_mobs)

			//Maybe add a "strange" severity that very rarely rolls, and would provide the crew with a more useful/fun variety of mobs?


/datum/round_event/scrubber_clog/start() //unedited andy



/datum/round_event_control/scrubber_clog/major
	name = "Major Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 12
	max_occurrences = 3


/datum/round_event/scrubber_clog/major
	severity = "Major"





/datum/round_event_control/scrubber_clog/critical
	name = "Critical Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog/critical
	weight = 8
	max_occurrences = 1

/datum/round_event/scrubber_clog/critical
	severity = "Critical"
	maximum_spawns = 2


