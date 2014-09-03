
datum/event/viral_infection
	var/severity = 1

datum/event/viral_infection/setup()
	announceWhen = rand(0, 3000)
	endWhen = announceWhen + 1
	severity = rand(1, 3)

datum/event/viral_infection/announce()
	biohazard_alert()

datum/event/viral_infection/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(severity > 0 && candidates.len)
		infect_mob_random_lesser(candidates[1])
		candidates.Remove(candidates[1])
		severity--
