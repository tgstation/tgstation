/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in shuffle(living_mob_list))
		var/foundAlready = 0	//don't infect someone that already has the virus
		for(var/datum/disease/D in H.viruses)
			foundAlready = 1
		if(H.stat == 2 || foundAlready)
			continue

		var/datum/disease/D = new /datum/disease/appendicitis
		D.holder = H
		D.affected_mob = H
		H.viruses += D
		break