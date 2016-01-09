/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/Found(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(!L.stat)
			return L
		else
			enemies -= L
	else if(istype(A, /obj/mecha))
		var/obj/mecha/M = A
		if(M.occupant)
			return A

/mob/living/simple_animal/hostile/retaliate/ListTargets()
	if(!enemies.len)
		return list()
	var/list/see = ..()
	see &= enemies // Remove all entries that aren't in enemies
	return see

/mob/living/simple_animal/hostile/retaliate/proc/Retaliate()
	var/list/around = view(src, vision_range)

	for(var/atom/movable/A in around)
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/M = A
			var/faction_check = 0
			for(var/F in faction)
				if(F in M.faction)
					faction_check = 1
					break
			if(faction_check && attack_same || !faction_check)
				enemies |= M
		else if(istype(A, /obj/mecha))
			var/obj/mecha/M = A
			if(M.occupant)
				enemies |= M
				enemies |= M.occupant

	for(var/mob/living/simple_animal/hostile/retaliate/H in around)
		var/retaliate_faction_check = 0
		for(var/F in faction)
			if(F in H.faction)
				retaliate_faction_check = 1
				break
		if(retaliate_faction_check && !attack_same && !H.attack_same)
			H.enemies |= enemies
	return 0

/mob/living/simple_animal/hostile/retaliate/adjustBruteLoss(damage)
	..(damage)
	if(stat == CONSCIOUS)
		Retaliate()
