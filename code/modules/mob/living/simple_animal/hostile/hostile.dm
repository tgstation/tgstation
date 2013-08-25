/mob/living/simple_animal/hostile
	faction = "hostile"
	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/target
	var/attack_same = 0
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype
	var/move_to_delay = 2 //delay for the automated movement.
	var/list/friends = list()
	var/vision_range = 10
	stop_automated_movement_when_pulled = 0

/mob/living/simple_animal/hostile/proc/FindTarget()

	var/atom/T = null
	stop_automated_movement = 0
	for(var/atom/A in ListTargets())

		var/atom/F = Found(A)
		if(F)
			T = F
			break

		if(isliving(A))
			var/mob/living/L = A
			if(L.faction == src.faction && !attack_same)
				continue
			else if(L in friends)
				continue
			else
				if(!L.stat)
					T = L
					break

		else if(istype(A, /obj/mecha)) // Our line of sight stuff was already done in ListTargets().
			var/obj/mecha/M = A
			if (M.occupant)
				T = M
				break

	return T

/mob/living/simple_animal/hostile/proc/GiveTarget(var/new_target)
	target = new_target
	stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/proc/Goto(var/target, var/delay)
	walk_to(src, target, 1, delay)

/mob/living/simple_animal/hostile/proc/Found(var/atom/A)
	return

/mob/living/simple_animal/hostile/proc/MoveToTarget()
	stop_automated_movement = 1
	if(!target || SA_attackable(target))
		LoseTarget()
	if(target in ListTargets())
		if(ranged)
			if(get_dist(src, target) <= 6)
				OpenFire(target)
			else
				Goto(target, move_to_delay)
		else
			stance = HOSTILE_STANCE_ATTACKING
			Goto(target, move_to_delay)

/mob/living/simple_animal/hostile/proc/AttackTarget()

	stop_automated_movement = 1
	if(!target || SA_attackable(target))
		LoseTarget()
		return 0
	if(!(target in ListTargets()))
		LostTarget()
		return 0
	if(get_dist(src, target) <= 1)	//Attacking
		AttackingTarget()
		return 1

/mob/living/simple_animal/hostile/proc/AttackingTarget()
	if(isliving(target))
		var/mob/living/L = target
		L.attack_animal(src)
		return L
	if(istype(target,/obj/mecha))
		var/obj/mecha/M = target
		M.attack_animal(src)
		return M

/mob/living/simple_animal/hostile/proc/LoseTarget()
	stance = HOSTILE_STANCE_IDLE
	target = null
	walk(src, 0)

/mob/living/simple_animal/hostile/proc/LostTarget()
	stance = HOSTILE_STANCE_IDLE
	walk(src, 0)


/mob/living/simple_animal/hostile/proc/ListTargets(var/override = -1)

	// Allows you to override how much the mob can see. Defaults to vision_range if none is entered.
	if(override == -1)
		override = vision_range

	var/list/L = hearers(src, override)
	for(var/obj/mecha/M in mechas_list)
		// Will check the distance before checking the line of sight, if the distance is small enough.
		if(get_dist(M, src) <= override && can_see(src, M, override))
			L += M
	return L

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
				var/new_target = FindTarget()
				GiveTarget(new_target)

			if(HOSTILE_STANCE_ATTACK)
				DestroySurroundings()
				MoveToTarget()

			if(HOSTILE_STANCE_ATTACKING)
				DestroySurroundings()
				AttackTarget()

/mob/living/simple_animal/hostile/proc/OpenFire(var/the_target)
	var/target = the_target
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
	target = null
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
