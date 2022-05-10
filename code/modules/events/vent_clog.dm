/datum/round_event_control/scrubber_clog
	name = "Minor Scrubber Clog"
	typepath = /datum/round_event/scrubber_clog
	weight = 12
	max_occurrences = 3

/datum/round_event/scrubber_clog
	announceWhen = 1
	startWhen = 10
	var/scrubber //Scrubber selected for the event
	var/spawned_mob //What mob will spawn out of the vents
	var/severity = "Minor" //Severity of the event (how dangerous are the spawned mobs, and it what quantity)
	var/maximum_spawns //Cap on the number of spawned mobs that can be alive at once

/datum/round_event/scrubber_clog/announce()
	priority_announce("[severity] biological obstruction detected in the ventilation network. Blockage is believed to be in the [get_area(scrubber)] area.", "Custodial Notification")

/datum/round_event/scrubber_clog/setup()
	scrubber = get_scrubber()
	if(!scrubber)
		CRASH("Unable to find suitable scrubber.")
	spawned_mob = get_mob()

/datum/round_event/scrubber_clog/proc/get_scrubber()
	var/list/scrubber_list
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/scrubber in GLOB.machines)
		var/turf/scrubber_turf = get_turf(scrubber)
		if(scrubber_turf && is_station_level(scrubber_turf.z) && !scrubber.welded)
			scrubber_list += scrubber
	return pick(scrubber_list)

/datum/round_event/scrubber_clog/proc/get_mob() //picks from mob list of some sorts, use switches based on severity for which mob list to pick from





/datum/round_event/scrubber_clog/start() //unedited andy







