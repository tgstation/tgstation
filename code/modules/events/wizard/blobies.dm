/datum/round_event_control/wizard/blobies //avast!
	name = "Zombie Outbreak"
	weight = 3
	typepath = /datum/round_event/wizard/blobies
	max_occurrences = 3
	description = "Spawns a blob spore on every corpse."

/datum/round_event/wizard/blobies/start()

	for(var/mob/living/carbon/human/H in GLOB.dead_mob_list)
		new /mob/living/simple_animal/hostile/blob/blobspore(H.loc)
