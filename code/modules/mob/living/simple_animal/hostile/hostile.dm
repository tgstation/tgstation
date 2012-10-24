/mob/living/simple_animal/hostile

	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/stance_step = 0				//Used to delay checks depending on what stance the hostile
	var/mob/living/target_mob		//Once the bear enters attack stance, it will try to chase this mob. This it to prevent it changing it's mind between multiple mobs.
	var/attack_same = 0

/mob/living/simple_animal/hostile/proc/FindTarget()

	var/atom/T = null
	stop_automated_movement = 0
	stance_step++
	if(stance_step > 5)
		stance_step = 0
		for(var/atom/A in ListTargets())

			if(!attack_same && istype(A, src.type))
				continue

			if(isliving(A))
				var/mob/living/L = A
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
		stance_step = step //Make it very alert, so it quickly attacks again if a mob returns
	if(target_mob in ListTargets())
		walk_to(src, target_mob, 1, 3)
		stance = HOSTILE_STANCE_ATTACKING
		stance_step = 0

/mob/living/simple_animal/hostile/proc/AttackTarget()

	stop_automated_movement = 1
	stance_step++
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

/mob/living/simple_animal/hostile/proc/LoseTarget(var/step = 3)
	stance = HOSTILE_STANCE_IDLE
	stance_step = step
	target_mob = null
	walk(src, 0)

/mob/living/simple_animal/hostile/proc/LostTarget(var/step = 1)
	stance = HOSTILE_STANCE_IDLE
	stance_step = step
	walk(src, 0)


/mob/living/simple_animal/hostile/proc/ListTargets()
	return view(src, 7)

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

			if(HOSTILE_STANCE_ATTACK)	//This one should only be active for one tick
				MoveToTarget()

			if(HOSTILE_STANCE_ATTACKING)
				AttackTarget()
