/datum/round_event_control/spontaneous_appendicitis
	name = "Spontaneous Appendicitis"
	typepath = /datum/round_event/spontaneous_appendicitis
	weight = 20
	max_occurrences = 4
	earliest_start = 6000
	min_players = 5 // To make your chance of getting help a bit higher.

/datum/round_event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		if(!H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.getorgan(/obj/item/organ/appendix)) //Don't give the disease to some who lacks it, only for it to be auto-cured
			continue
		var/foundAlready = FALSE	//don't infect someone that already has appendicitis
		for(var/datum/disease/appendicitis/A in H.viruses)
			foundAlready = TRUE
			break
		if(foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		H.ForceContractDisease(D)
		break