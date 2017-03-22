/datum/round_event_control/spontaneous_appendicitis
	name = "Spontaneous Appendicitis"
	typepath = /datum/round_event/spontaneous_appendicitis
	weight = 20
	max_occurrences = 4
	earliest_start = 6000
	min_players = 5 // To make your chance of getting help a bit higher.

/datum/round_event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list))
		var/foundAlready = 0	//don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		H.ForceContractDisease(D)
		break