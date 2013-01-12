/mob/living/simple_animal/hostile/retaliate
	var/list/enemies = list()

/mob/living/simple_animal/hostile/retaliate/Found(var/atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L in enemies)
			if(!L.stat)
				stance = HOSTILE_STANCE_ATTACK
				return L
			else
				enemies -= L


/mob/living/simple_animal/hostile/retaliate/proc/retaliate()
	..()
	var/list/mobs_around = viewers(src, 7)

	for(var/mob/living/M in mobs_around)
		if(!attack_same && istype(M, type))
			enemies += M

	for(var/mob/living/simple_animal/hostile/retaliate/H in mobs_around)
		if(istype(H, src.type))
			H.enemies += enemies
	return 0

/mob/living/simple_animal/hostile/retaliate/adjustBruteLoss(var/damage)
	..(damage)
	retaliate()
