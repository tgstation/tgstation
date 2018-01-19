/datum/round_event_control/mass_hallucination
	name = "Mass Hallucination"
	typepath = /datum/round_event/mass_hallucination
	weight = 10
	max_occurrences = 2
	min_players = 1

/datum/round_event/mass_hallucination
	fakeable = FALSE

/datum/round_event/mass_hallucination/start()
	switch(rand(1,4))
		if(1) //same sound for everyone
			var/sound = pick("explosion","far_explosion","phone","alarm","hallelujah","creepy","ratvar","shuttle_dock",
				"wall_decon","door_hack","blob_alert","tesla","malf_ai","meteors")
			for(var/mob/living/carbon/C in GLOB.alive_mob_list)
				new /datum/hallucination/sounds(C, TRUE, sound)
		if(2 to 4)
			var/picked_hallucination = pick(	/datum/hallucination/bolts,
												/datum/hallucination/whispers,
												/datum/hallucination/message,
												/datum/hallucination/bolts,
												/datum/hallucination/fake_flood,
												/datum/hallucination/battle,
												/datum/hallucination/fire,
												/datum/hallucination/self_delusion,
												/datum/hallucination/fakeattacker,
												/datum/hallucination/death,
												/datum/hallucination/xeno_attack,
												/datum/hallucination/delusion,
												/datum/hallucination/oh_yeah)
			for(var/mob/living/carbon/C in GLOB.alive_mob_list)
				new picked_hallucination(C, TRUE)