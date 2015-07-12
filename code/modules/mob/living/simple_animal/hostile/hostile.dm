/mob/living/simple_animal/hostile
	faction = list("hostile")
	stop_automated_movement_when_pulled = 0
	environment_smash = 1 //Set to 1 to break closets,tables,racks, etc; 2 for walls; 3 for rwalls
	var/stance = HOSTILE_STANCE_IDLE	//Used to determine behavior
	var/atom/target
	var/ranged = 0
	var/rapid = 0
	var/projectiletype
	var/projectilesound
	var/casingtype
	var/move_to_delay = 3 //delay for the automated movement.
	var/list/friends = list()

	var/ranged_message = "fires" //Fluff text for ranged mobs
	var/ranged_cooldown = 0 //What the starting cooldown is on ranged attacks
	var/ranged_cooldown_cap = 3 //What ranged attacks, after being used are set to, to go back on cooldown, defaults to 3 life() ticks
	var/retreat_distance = null //If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/minimum_distance = 1 //Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance


//These vars are related to how mobs locate and target
	var/robust_searching = 0 //By default, mobs have a simple searching method, set this to 1 for the more scrutinous searching (stat_attack, stat_exclusive, etc), should be disabled on most mobs
	var/vision_range = 9 //How big of an area to search for targets in, a vision of 9 attempts to find targets as soon as they walk into screen view
	var/aggro_vision_range = 9 //If a mob is aggro, we search in this radius. Defaults to 9 to keep in line with original simple mob aggro radius
	var/idle_vision_range = 9 //If a mob is just idling around, it's vision range is limited to this. Defaults to 9 to keep in line with original simple mob aggro radius
	var/search_objects = 0 //If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3
	var/list/wanted_objects = list() //A list of objects that will be checked against to attack, should we have search_objects enabled
	var/stat_attack = 0 //Mobs with stat_attack to 1 will attempt to attack things that are unconscious, Mobs with stat_attack set to 2 will attempt to attack the dead.
	var/stat_exclusive = 0 //Mobs with this set to 1 will exclusively attack things defined by stat_attack, stat_attack 2 means they will only attack corpses
	var/attack_same = 0 //Set us to 1 to allow us to attack our own faction, or 2, to only ever attack our own faction

	var/AIStatus = AI_ON //The Status of our AI, can be set to AI_ON (On, usual processing), AI_SLEEP (Will not process, but will return to AI_ON if an enemy comes near), AI_OFF (Off, Not processing ever)

/mob/living/simple_animal/hostile/Life()

	. = ..()
	if(!.) //dead
		walk(src, 0) //stops walking
		return 0
	if(ranged)
		ranged_cooldown--
	if(client)
		return 0
	if(!AICanContinue())
		return 0
	if(!stat)
		switch(stance)
			if(HOSTILE_STANCE_IDLE)
				if(environment_smash)
					EscapeConfinement()
				FindTarget()

			if(HOSTILE_STANCE_ATTACK)
				MoveToTarget()
				DestroySurroundings()

			if(HOSTILE_STANCE_ATTACKING)
				AttackTarget()
				DestroySurroundings()

		if(AIShouldSleep())
			AIStatus = AI_SLEEP


//////////////HOSTILE MOB TARGETTING AND AGGRESSION////////////


/mob/living/simple_animal/hostile/proc/ListTargets()//Step 1, find out what we can see
	var/list/L = list()
	if(!search_objects)
		var/list/Mobs = hearers(vision_range, src) - src //Remove self, so we don't suicide
		L += Mobs
		for(var/obj/mecha/M in mechas_list)
			if(get_dist(M, src) <= vision_range && can_see(src, M, vision_range))
				L += M
	else
		var/list/Objects = oview(vision_range, src)
		L += Objects
	return L

/mob/living/simple_animal/hostile/proc/FindTarget()//Step 2, filter down possible targets to things we actually care about
	var/list/Targets = list()
	var/Target
	for(var/atom/A in ListTargets())
		if(Found(A))//Just in case people want to override targetting
			var/list/FoundTarget = list()
			FoundTarget += A
			Targets = FoundTarget
			break
		if(CanAttack(A))//Can we attack it?
			Targets += A
			continue
	Target = PickTarget(Targets)
	GiveTarget(Target)
	return Target //We now have a target

/mob/living/simple_animal/hostile/proc/Found(var/atom/A)//This is here as a potential override to pick a specific target if available
	return

/mob/living/simple_animal/hostile/proc/PickTarget(var/list/Targets)//Step 3, pick amongst the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		for(var/atom/A in Targets)
			var/target_dist = get_dist(src, target)
			var/possible_target_distance = get_dist(src, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)//We didnt find nothin!
		return
	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target

/mob/living/simple_animal/hostile/CanAttack(var/atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return 0
	if(search_objects < 2)
		if(istype(the_target, /obj/mecha))
			var/obj/mecha/M = the_target
			if(M.occupant)//Just so we don't attack empty mechs
				if(CanAttack(M.occupant))
					return 1
		if(isliving(the_target))
			var/mob/living/L = the_target
			var/faction_check = 0
			for(var/F in faction)
				if(F in L.faction)
					faction_check = 1
					break
			if(robust_searching)
				if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive == 1)
					return 0
				if(faction_check && !attack_same || !faction_check && attack_same == 2)
					return 0
				if(L in friends)
					return 0
			else
				if(L.stat)
					return 0
				if(faction_check && !attack_same)
					return 0
			return 1
	if(isobj(the_target))
		if(the_target.type in wanted_objects)
			return 1
	return 0

/mob/living/simple_animal/hostile/proc/GiveTarget(var/new_target)//Step 4, give us our selected target
	target = new_target
	if(target != null)
		Aggro()
		stance = HOSTILE_STANCE_ATTACK
	return

/mob/living/simple_animal/hostile/proc/MoveToTarget()//Step 5, handle movement between us and our target
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return
	if(target in ListTargets())
		var/target_distance = get_dist(src,target)
		if(ranged)//We ranged? Shoot at em
			if(target_distance >= 2 && ranged_cooldown <= 0)//But make sure they're a tile away at least, and our range attack is off cooldown
				OpenFire(target)
		if(retreat_distance != null)//If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance)//If target's closer than our retreat distance, run
				walk_away(src,target,retreat_distance,move_to_delay)
			else
				Goto(target,move_to_delay,minimum_distance)//Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)
		if(isturf(loc) && target.Adjacent(src))	//If they're next to us, attack
			AttackingTarget()
		return
	if(environment_smash)
		if(target.loc != null && get_dist(src, target.loc) <= vision_range)//We can't see our target, but he's in our vision range still
			if(environment_smash >= 2)//If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return
			else
				if(FindHidden())
					return
	LostTarget()

/mob/living/simple_animal/hostile/proc/Goto(var/target, var/delay, var/minimum_distance)
	walk_to(src, target, minimum_distance, delay)

/mob/living/simple_animal/hostile/adjustBruteLoss(var/damage)
	..(damage)
	if(!client && !stat && search_objects < 3)//Not unconscious, and we don't ignore mobs
		if(search_objects)//Turn off item searching and ignore whatever item we were looking at, we're more concerned with fight or flight
			search_objects = 0
			target = null
		if(stance == HOSTILE_STANCE_IDLE)//If we took damage while idle, immediately attempt to find the source of it so we find a living target
			Aggro()
			FindTarget()
		if(stance == HOSTILE_STANCE_ATTACK)//No more pulling a mob forever and having a second player attack it, it can switch targets now if it finds a more suitable one
			if(target != null && prob(40))
				FindTarget()

/mob/living/simple_animal/hostile/proc/AttackTarget()

	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return 0
	if(!(target in ListTargets()))
		LostTarget()
		return 0
	if(isturf(loc) && target.Adjacent(src))
		AttackingTarget()
		return 1

/mob/living/simple_animal/hostile/proc/AttackingTarget()
	target.attack_animal(src)

/mob/living/simple_animal/hostile/proc/Aggro()
	vision_range = aggro_vision_range

/mob/living/simple_animal/hostile/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = idle_vision_range

/mob/living/simple_animal/hostile/proc/LoseTarget()
	stance = HOSTILE_STANCE_IDLE
	target = null
	walk(src, 0)
	LoseAggro()

/mob/living/simple_animal/hostile/proc/LostTarget()
	stance = HOSTILE_STANCE_IDLE
	walk(src, 0)
	LoseAggro()

//////////////END HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/death(gibbed)
	LoseAggro()
	..(gibbed)
	walk(src, 0)

/mob/living/simple_animal/hostile/proc/OpenFire(var/the_target)

	var/target = the_target
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [target]!</span>")

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
	ranged_cooldown = ranged_cooldown_cap
	return

/mob/living/simple_animal/hostile/proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return

	var/obj/item/projectile/A = new projectiletype(user:loc)
	playsound(user, projectilesound, 100, 1)
	if(!A)	return

	if (!istype(target, /turf))
		qdel(A)
		return
	A.current = target
	A.firer = src
	A.yo = target:y - start:y
	A.xo = target:x - start:x
	A.fire()
	return

/mob/living/simple_animal/hostile/proc/DestroySurroundings()
	if(environment_smash)
		EscapeConfinement()
		for(var/dir in cardinal)
			var/turf/T = get_step(src, dir)
			if(istype(T, /turf/simulated/wall) || istype(T, /turf/simulated/mineral))
				if(T.Adjacent(src))
					T.attack_animal(src)
			for(var/atom/A in T)
				if(!A.Adjacent(src))
					continue
				if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
					A.attack_animal(src)
	return

/mob/living/simple_animal/hostile/proc/EscapeConfinement()
	if(buckled)
		buckled.attack_animal(src)
	if(!isturf(src.loc) && src.loc != null)//Did someone put us in something?
		var/atom/A = src.loc
		A.attack_animal(src)//Bang on it till we get out
	return

/mob/living/simple_animal/hostile/proc/FindHidden()
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		var/atom/A = target.loc
		Goto(A,move_to_delay,minimum_distance)
		if(A.Adjacent(src))
			A.attack_animal(src)
		return 1

/mob/living/simple_animal/hostile/RangedAttack(var/atom/A, var/params) //Player firing
	if(ranged && ranged_cooldown <= 0)
		target = A
		OpenFire(A)
	..()



////// AI Status ///////
/mob/living/simple_animal/hostile/proc/AICanContinue()
	switch(AIStatus)
		if(AI_ON)
			. = 1
		if(AI_SLEEP)
			if(AIShouldWake())
				. = 1
				AIStatus = AI_ON //Wake up for more than one Life() cycle.
			else
				. = 0
		if(AI_OFF)
			. = 0


//Returns 1 if the AI should wake up
//Returns 0 if the AI should remain asleep
/mob/living/simple_animal/hostile/proc/AIShouldWake()
	. = 0
	if(FindTarget())
		. = 1


//Convenience
/mob/living/simple_animal/hostile/proc/AIShouldSleep()
	. = !(AIShouldWake())
	if(. && stance != HOSTILE_STANCE_IDLE) //This proc was called before LoseTarget().
		LostTarget()
