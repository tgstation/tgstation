/datum/round_event_control/gravity_generator_blackout
	name = "Gravity Generator Blackout"
	typepath = /datum/round_event/gravity_generator_blackout
	weight = 30

/datum/round_event/gravity_generator_blackout
	announceWhen = 1

/datum/round_event/gravity_generator_blackout/announce(fake)
	var/alert = pick( "Gravnospheric anomalies detected. Temporary gravity field failure imminent.")

	if(prob(30) || fake) //most of the time, we don't want an announcement, allows quiet sabotage.
		priority_announce(alert)


/datum/round_event/gravity_generator_blackout/start()
	for(var/obj/machinery/gravity_generator/main/the_generator in GLOB.gravity_generators)
		the_generator.blackout
