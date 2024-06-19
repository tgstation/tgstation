/datum/round_event_control/gravity_generator_blackout
	name = "Gravity Generator Blackout"
	typepath = /datum/round_event/gravity_generator_blackout
	weight = 30
	category = EVENT_CATEGORY_ENGINEERING
	description = "Turns off the gravity generator."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4

/datum/round_event_control/gravity_generator_blackout/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	var/station_generator_exists = FALSE
	for(var/obj/machinery/gravity_generator/main/the_generator as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/gravity_generator/main))
		if(is_station_level(the_generator.z))
			station_generator_exists = TRUE

	if(!station_generator_exists)
		return FALSE

/datum/round_event/gravity_generator_blackout
	announce_when = 1
	start_when = 1
	announce_chance = 33

/datum/round_event/gravity_generator_blackout/announce(fake)
	priority_announce("Gravnospheric anomalies detected near [station_name()]. Manual reset of generators is required.", "Anomaly Alert", ANNOUNCER_GRANOMALIES)

/datum/round_event/gravity_generator_blackout/start()
	for(var/obj/machinery/gravity_generator/main/the_generator as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/gravity_generator/main))
		if(is_station_level(the_generator.z))
			the_generator.blackout()
