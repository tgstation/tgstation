/datum/round_event_control/wizard/blobies //avast!
	name = "Zombie Outbreak"
	weight = 3
	typepath = /datum/round_event/wizard/blobies/
	max_occurrences = 3
	earliest_start = 0

/datum/round_event/wizard/blobies/start()

	for(var/mob/living/carbon/human/H in dead_mob_list)
		new /mob/living/simple_animal/hostile/blobspore(H.loc)
