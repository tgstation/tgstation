datum/event/organ_failure
	var/severity = 1

datum/event/organ_failure/setup()
	announceWhen = rand(0, 300)
	endWhen = announceWhen + 1
	severity = rand(1, 3)

datum/event/organ_failure/announce()
	biohazard_alert(rand(3,7))
datum/event/organ_failure/start()
	var/list/candidates = list()	//list of candidate keys
	for(var/mob/living/carbon/human/G in player_list)
		if(G.mind && G.mind.current && G.mind.current.stat != DEAD && G.health > 70)
			candidates += G
	if(!candidates.len)	return
	candidates = shuffle(candidates)//Incorporating Donkie's list shuffle

	while(severity > 0 && candidates.len)
		var/mob/living/carbon/human/C = candidates[1]
		if(!C) continue
		// Bruise one of their organs
		var/datum/organ/internal/I = C.internal_organs_by_name[rand(1,C.internal_organs_by_name.len)]
		if(!I)
			candidates.Remove(C) // Bad candidate.
			severity--
			continue
		I.damage = I.min_bruised_damage
		candidates.Remove(C)
		severity--
