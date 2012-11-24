/mob/living/simple_animal/hostile
	faction = "hostile"
	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/mob/living/target_mob
	var/attack_same = 0
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype

/mob/living/simple_animal/hostile/proc/FindTarget()

	var/atom/T = null
	stop_automated_movement = 0
	for(var/atom/A in ListTargets())

		if(isliving(A))
			var/mob/living/L = A
			if(L.faction == src.faction && !attack_same)
				continue
			else
				if(!L.stat)
					stance = HOSTILE_STANCE_ATTACK
					T = L
					break
		if(istype(A, /obj/mecha))
			var/obj/mecha/M = A
			if (M.occupant)
				stance = HOSTILE_STANCE_ATTACK
				T = M
				break
	return T

/mob/living/simple_animal/hostile/proc/MoveToTarget(var/step = 5)
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		stance = HOSTILE_STANCE_IDLE
	if(target_mob in ListTargets())
		if(ranged)
			if(get_dist(src, target_mob) <= 6)
				OpenFire(target_mob)
		else
			stance = HOSTILE_STANCE_ATTACKING
		walk_to(src, target_mob, 1, 2)

/mob/living/simple_animal/hostile/proc/AttackTarget()

	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		LoseTarget()
		return
	if(!(target_mob in ListTargets()))
		LostTarget()
		return
	if(get_dist(src, target_mob) <= 1)	//Attacking
		AttackingTarget()

/mob/living/simple_animal/hostile/proc/AttackingTarget()
	if(isliving(target_mob))
		var/mob/living/L = target_mob
		L.attack_animal(src)
		return L
	if(istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		M.attack_animal(src)
		return M

/mob/living/simple_animal/hostile/proc/LoseTarget()
	stance = HOSTILE_STANCE_IDLE
	target_mob = null
	walk(src, 0)

/mob/living/simple_animal/hostile/proc/LostTarget()
	stance = HOSTILE_STANCE_IDLE
	walk(src, 0)


/mob/living/simple_animal/hostile/proc/ListTargets()
	return view(src, 10)

/mob/living/simple_animal/hostile/Die()
	..()
	walk(src, 0)

/mob/living/simple_animal/hostile/Life()

	. = ..()
	if(!.)
		walk(src, 0)
		return 0
	if(client)
		return 0

	if(!stat)
		switch(stance)
			if(HOSTILE_STANCE_IDLE)
				target_mob = FindTarget()

			if(HOSTILE_STANCE_ATTACK)
				DestroySurroundings()
				MoveToTarget()

			if(HOSTILE_STANCE_ATTACKING)
				DestroySurroundings()
				AttackTarget()



/mob/living/simple_animal/hostile/proc/OpenFire(target_mob)
	var/target = target_mob
	visible_message("\red <b>[src]</b> fires at [target]!", 1)

	var/tturf = get_turf(target)
	if(rapid)
		spawn(1)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(4)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(6)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
	else
		Shoot(tturf, src.loc, src)
		if(casingtype)
			new casingtype

	stance = HOSTILE_STANCE_IDLE
	target_mob = null
	return


/mob/living/simple_animal/hostile/proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return

	var/obj/item/projectile/A = new projectiletype(user:loc)
	playsound(user, projectilesound, 100, 1)
	if(!A)	return

	if (!istype(target, /turf))
		del(A)
		return
	A.current = target
	A.yo = target:y - start:y
	A.xo = target:x - start:x
	spawn( 0 )
		A.process()
	return

/mob/living/simple_animal/hostile/proc/DestroySurroundings()
	for(var/dir in cardinal) // North, South, East, West
		var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
		if(istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/closet) || istype(obstacle, /obj/structure/table) || istype(obstacle, /obj/structure/grille))
			obstacle.attack_animal(src)