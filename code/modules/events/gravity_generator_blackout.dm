/datum/round_event_control/gravity_generator_blackout
	name = "Gravity Generator Blackout"
	typepath = /datum/round_event/gravity_generator_blackout
	weight = 30

/datum/round_event/gravity_generator_blackout
	announceWhen = 1
	startWhen = 1
	announceChance = 33

/datum/round_event/gravity_generator_blackout/announce(fake)
	priority_announce("Gravnospheric anomalies detected near [station_name()]. Manual reset of generators is required.")

/datum/round_event/gravity_generator_blackout/start()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.machines)
		the_generator.blackout()
