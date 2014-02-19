
datum/event/viral_outbreak
	var/severity = 1

datum/event/viral_outbreak/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1
	severity = rand(2, 4)

datum/event/viral_outbreak/announce()
	biohazard_alert()

datum/event/viral_outbreak/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(severity > 0 && candidates.len)
		if(prob(33))
			infect_mob_random_lesser(candidates[1])
		else
			infect_mob_random_greater(candidates[1])

		candidates.Remove(candidates[1])
		severity--
