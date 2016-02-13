/datum/event/mass_hallucination


/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.hallucination += rand(100, 250)

/datum/event/mass_drunk
	startWhen = 10
	announceWhen = 0

/datum/event/mass_drunk/start()
	for(var/mob/living/carbon/C in living_mob_list)
		C.dizziness = 18
		C.confused = 18
		C.stuttering = 20

datum/event/mass_drunk/announce()
	command_alert("The station is about to pass through a cloud of unknown chemical composition. Chemical infiltration into the air supply is possible.", "Unknown Chemical Cloud")
