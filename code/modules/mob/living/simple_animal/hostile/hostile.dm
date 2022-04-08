/mob/living/simple_animal/hostile
	faction = list("hostile")
	stop_automated_movement_when_pulled = 0
	obj_damage = 40
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES //Bitflags. Set to ENVIRONMENT_SMASH_STRUCTURES to break closets,tables,racks, etc; ENVIRONMENT_SMASH_WALLS for walls; ENVIRONMENT_SMASH_RWALLS for rwalls

	///The current target of our attacks, use GiveTarget and LoseTarget to set this var
	var/atom/target
	var/ranged = FALSE

	///How many shots per volley.
	var/rapid = 0

	///Time between rapid fire shots
	var/rapid_fire_delay = 2

	var/dodging = FALSE

	///We should dodge now
	var/approaching_target = FALSE

	///We should sidestep now
	var/in_melee = FALSE
	var/dodge_prob = 30

	///How many sidesteps per npcpool cycle when in melee
	var/sidestep_per_cycle = 1

	///set ONLY it and NULLIFY casingtype var, if we have ONLY projectile
	var/projectiletype
	var/projectilesound

	///set ONLY it and NULLIFY projectiletype, if we have projectile IN CASING
	var/casingtype

	///delay for the automated movement.
	var/move_to_delay = 3
	var/list/friends = list()
	var/list/emote_taunt = list()
	var/taunt_chance = 0

	///Number of melee attacks between each npc pool tick. Spread evenly.
	var/rapid_melee = 1

	///If target is close enough start preparing to hit them if we have rapid_melee enabled
	var/melee_queue_distance = 4

	///Fluff text for ranged mobs
	var/ranged_message = "fires"

	///What the current cooldown on ranged attacks is, generally world.time + ranged_cooldown_time
	var/ranged_cooldown = 0

	///How long, in deciseconds, the cooldown of ranged attacks is
	var/ranged_cooldown_time = 30

	///if it'll fire ranged attacks even if it lacks vision on its target, only works with environment smash
	var/ranged_ignores_vision = FALSE

	/// Should the ranged mob check for friendlies when shooting
	var/check_friendly_fire = 0

	///If our mob runs from players when they're too close, set in tile distance. By default, mobs do not retreat.
	var/retreat_distance = null

	///Minimum approach distance, so ranged mobs chase targets down, but still keep their distance set in tiles to the target, set higher to make mobs keep distance
	var/minimum_distance = 1

	///whether we should remove ourselves from the SSsimple_mobs processing list if our ai is turned off. saves processing time
	var/stop_life = TRUE


//These vars are related to how mobs locate and target

	///By default, mobs have a simple searching method, set this to 1 for the more scrutinous searching (stat_attack, stat_exclusive, etc), should be disabled on most mobs
	var/robust_searching = 0

	///How big of an area to search for targets in, a vision of 9 attempts to find targets as soon as they walk into screen view
	var/vision_range = 9

	///If a mob is aggro, we search in this radius. Defaults to 9 to keep in line with original simple mob aggro radius
	var/aggro_vision_range = 9

	///If we want to consider objects when searching around, set this to 1. If you want to search for objects while also ignoring mobs until hurt, set it to 2. To completely ignore mobs, even when attacked, set it to 3
	var/search_objects = 0

	///Timer for regaining our old search_objects value after being attacked
	var/search_objects_timer_id

	///the delay between being attacked and gaining our old search_objects value back
	var/search_objects_regain_time = 30

	///A typecache of objects types that will be checked against to attack, should we have search_objects enabled
	var/list/wanted_objects = list()

	///Mobs ignore mob/living targets with a stat lower than that of stat_attack. If set to DEAD, then they'll include corpses in their targets, if to HARD_CRIT they'll keep attacking until they kill, and so on.
	var/stat_attack = CONSCIOUS

	///Mobs with this set to TRUE will exclusively attack things defined by stat_attack, stat_attack DEAD means they will only attack corpses
	var/stat_exclusive = FALSE

	///Set us to TRUE to allow us to attack our own faction
	var/attack_same = 0

	///Use GET_TARGETS_FROM(mob) to access this.
	///Attempting to call GET_TARGETS_FROM(mob) when this var is null will just return mob as a base.
	///all range/attack/etc. calculations should be done from the atom this weakrefs, useful for Vehicles and such.
	var/datum/weakref/targets_from

	///if true, equivalent to having a wanted_objects list containing ALL objects.
	var/attack_all_objects = FALSE

	///id for a timer to call LoseTarget(), used to stop mobs fixating on a target they can't reach
	var/lose_patience_timer_id

	///30 seconds by default, so there's no major changes to AI behaviour, beyond actually bailing if stuck forever
	var/lose_patience_timeout = 300

/mob/living/simple_animal/hostile/Initialize(mapload)
	. = ..()
	wanted_objects = typecacheof(wanted_objects)

/mob/living/simple_animal/hostile/Destroy()
	//We can't use losetarget here because fucking cursed blobs override it to do nothing the motherfuckers
	GiveTarget(null)
	return ..()

/mob/living/simple_animal/hostile/Life(delta_time = SSSIMPLE_MOBS_DT, times_fired)
	. = ..()
	if(!.) //dead
		SSmove_manager.stop_looping(src)

/mob/living/simple_animal/hostile/handle_automated_action()
	if(AIStatus == AI_OFF || AIStatus == AI_DISTANCE_OFF)
		return FALSE
	var/list/possible_targets = ListTargets() //we look around for potential targets and make it a list for later use.

	if(environment_smash)
		EscapeConfinement()

	if(AICanContinue(possible_targets))
		var/atom/target_from = GET_TARGETS_FROM(src)
		if(!QDELETED(target) && !target_from.Adjacent(target))
			DestroyPathToTarget()
		if(!MoveToTarget(possible_targets))     //if we lose our target
			if(AIShouldSleep(possible_targets)) // we try to acquire a new one
				toggle_ai(AI_IDLE) // otherwise we go idle
	return TRUE

/mob/living/simple_animal/hostile/handle_automated_movement()
	. = ..()
	if(dodging && target && in_melee && isturf(loc) && isturf(target.loc))
		var/datum/cb = CALLBACK(src,.proc/sidestep)
		if(sidestep_per_cycle > 1) //For more than one just spread them equally - this could changed to some sensible distribution later
			var/sidestep_delay = SSnpcpool.wait / sidestep_per_cycle
			for(var/i in 1 to sidestep_per_cycle)
				addtimer(cb, (i - 1)*sidestep_delay)
		else //Otherwise randomize it to make the players guessing.
			addtimer(cb,rand(1,SSnpcpool.wait))

/mob/living/simple_animal/hostile/update_stamina()
	. = ..()
	move_to_delay = (initial(move_to_delay) + (staminaloss * 0.06))

/mob/living/simple_animal/hostile/proc/sidestep()
	if(!target || !isturf(target.loc) || !isturf(loc) || stat == DEAD)
		return
	var/target_dir = get_dir(src,target)

	var/static/list/cardinal_sidestep_directions = list(-90,-45,0,45,90)
	var/static/list/diagonal_sidestep_directions = list(-45,0,45)
	var/chosen_dir = 0
	if (target_dir & (target_dir - 1))
		chosen_dir = pick(diagonal_sidestep_directions)
	else
		chosen_dir = pick(cardinal_sidestep_directions)
	if(chosen_dir)
		chosen_dir = turn(target_dir,chosen_dir)
		Move(get_step(src,chosen_dir))
		face_atom(target) //Looks better if they keep looking at you when dodging

/mob/living/simple_animal/hostile/attacked_by(obj/item/I, mob/living/user)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client && user)
		FindTarget(list(user), 1)
	return ..()

/mob/living/simple_animal/hostile/bullet_act(obj/projectile/P)
	if(stat == CONSCIOUS && !target && AIStatus != AI_OFF && !client)
		if(P.firer && get_dist(src, P.firer) <= aggro_vision_range)
			FindTarget(list(P.firer), 1)
		Goto(P.starting, move_to_delay, 3)
	return ..()

//////////////HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/proc/ListTargets() //Step 1, find out what we can see
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(!search_objects)
		. = hearers(vision_range, target_from) - src //Remove self, so we don't suicide

		var/static/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))

		for(var/obj/hostile_machine in view(vision_range, target_from))
			if(hostile_machines[hostile_machine.type] && can_see(target_from, hostile_machine, vision_range))
				. += hostile_machine

	else
		. = oview(vision_range, target_from)

/mob/living/simple_animal/hostile/proc/FindTarget(list/possible_targets, HasTargetsList = 0)//Step 2, filter down possible targets to things we actually care about
	. = list()
	if(!HasTargetsList)
		possible_targets = ListTargets()
	for(var/atom/possible_target as anything in possible_targets)
		if(Found(possible_target))//Just in case people want to override targetting
			. = list(possible_target)
			break
		if(CanAttack(possible_target))//Can we attack it?
			. += possible_target
			continue
	var/Target = PickTarget(.)
	GiveTarget(Target)
	return Target //We now have a target



/mob/living/simple_animal/hostile/proc/PossibleThreats()
	. = list()
	for(var/pos_targ in ListTargets())
		var/atom/A = pos_targ
		if(Found(A))
			. = list(A)
			break
		if(CanAttack(A))
			. += A
			continue



/mob/living/simple_animal/hostile/proc/Found(atom/A)//This is here as a potential override to pick a specific target if available
	return

/mob/living/simple_animal/hostile/proc/PickTarget(list/Targets)//Step 3, pick amongst the possible, attackable targets
	if(target != null)//If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets
		var/atom/target_from = GET_TARGETS_FROM(src)
		for(var/pos_targ in Targets)
			var/atom/A = pos_targ
			var/target_dist = get_dist(target_from, target)
			var/possible_target_distance = get_dist(target_from, A)
			if(target_dist < possible_target_distance)
				Targets -= A
	if(!Targets.len)//We didnt find nothin!
		return
	var/chosen_target = pick(Targets)//Pick the remaining targets (if any) at random
	return chosen_target

// Please do not add one-off mob AIs here, but override this function for your mob
/mob/living/simple_animal/hostile/CanAttack(atom/the_target)//Can we actually attack a possible target?
	if(isturf(the_target) || !the_target) // bail out on invalids
		return FALSE

	if(ismob(the_target)) //Target is in godmode, ignore it.
		var/mob/M = the_target
		if(M.status_flags & GODMODE)
			return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE
	if(search_objects < 2)
		if(isliving(the_target))
			var/mob/living/L = the_target
			var/faction_check = faction_check_mob(L)
			if(robust_searching)
				if(faction_check && !attack_same)
					return FALSE
				if(L.stat > stat_attack)
					return FALSE
				if(L in friends)
					return FALSE
			else
				if((faction_check && !attack_same) || L.stat)
					return FALSE
			return TRUE

		if(ismecha(the_target))
			var/obj/vehicle/sealed/mecha/M = the_target
			for(var/occupant in M.occupants)
				if(CanAttack(occupant))
					return TRUE

		if(istype(the_target, /obj/machinery/porta_turret))
			var/obj/machinery/porta_turret/P = the_target
			if(P.in_faction(src)) //Don't attack if the turret is in the same faction
				return FALSE
			if(P.has_cover &&!P.raised) //Don't attack invincible turrets
				return FALSE
			if(P.machine_stat & BROKEN) //Or turrets that are already broken
				return FALSE
			return TRUE

	if(isobj(the_target))
		if(attack_all_objects || is_type_in_typecache(the_target, wanted_objects))
			return TRUE

	return FALSE

/mob/living/simple_animal/hostile/proc/GiveTarget(new_target)//Step 4, give us our selected target
	add_target(new_target)
	LosePatience()
	if(target != null)
		GainPatience()
		Aggro()
		return TRUE

//What we do after closing in
/mob/living/simple_animal/hostile/proc/MeleeAction(patience = TRUE)
	if(rapid_melee > 1)
		var/datum/callback/cb = CALLBACK(src, .proc/CheckAndAttack)
		var/delay = SSnpcpool.wait / rapid_melee
		for(var/i in 1 to rapid_melee)
			addtimer(cb, (i - 1)*delay)
	else
		AttackingTarget()
	if(patience)
		GainPatience()

/mob/living/simple_animal/hostile/proc/CheckAndAttack()
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(target && isturf(target_from.loc) && target.Adjacent(target_from) && !incapacitated())
		AttackingTarget()

/mob/living/simple_animal/hostile/proc/MoveToTarget(list/possible_targets)//Step 5, handle movement between us and our target
	stop_automated_movement = 1
	if(!target || !CanAttack(target))
		LoseTarget()
		return FALSE
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(target in possible_targets)
		var/turf/T = get_turf(src)
		if(target.z != T.z)
			LoseTarget()
			return FALSE
		var/target_distance = get_dist(target_from,target)
		if(ranged) //We ranged? Shoot at em
			if(!target.Adjacent(target_from) && ranged_cooldown <= world.time) //But make sure they're not in range for a melee attack and our range attack is off cooldown
				OpenFire(target)
		if(!Process_Spacemove()) //Drifting
			SSmove_manager.stop_looping(src)
			return TRUE
		if(retreat_distance != null) //If we have a retreat distance, check if we need to run from our target
			if(target_distance <= retreat_distance) //If target's closer than our retreat distance, run
				SSmove_manager.move_away(src, target, retreat_distance, move_to_delay, flags = MOVEMENT_LOOP_IGNORE_GLIDE)
			else
				Goto(target,move_to_delay,minimum_distance) //Otherwise, get to our minimum distance so we chase them
		else
			Goto(target,move_to_delay,minimum_distance)
		if(target)
			if(isturf(target_from.loc) && target.Adjacent(target_from)) //If they're next to us, attack
				MeleeAction()
			else
				if(rapid_melee > 1 && target_distance <= melee_queue_distance)
					MeleeAction(FALSE)
				in_melee = FALSE //If we're just preparing to strike do not enter sidestep mode
			return TRUE
		return FALSE
	if(environment_smash)
		if(target.loc != null && get_dist(target_from, target.loc) <= vision_range) //We can't see our target, but he's in our vision range still
			if(ranged_ignores_vision && ranged_cooldown <= world.time) //we can't see our target... but we can fire at them!
				OpenFire(target)
			if((environment_smash & ENVIRONMENT_SMASH_WALLS) || (environment_smash & ENVIRONMENT_SMASH_RWALLS)) //If we're capable of smashing through walls, forget about vision completely after finding our target
				Goto(target,move_to_delay,minimum_distance)
				FindHidden()
				return TRUE
			else
				if(FindHidden())
					return TRUE
	LoseTarget()
	return FALSE

/mob/living/simple_animal/hostile/proc/Goto(target, delay, minimum_distance)
	if(target == src.target)
		approaching_target = TRUE
	else
		approaching_target = FALSE
	SSmove_manager.move_to(src, target, minimum_distance, delay, flags = MOVEMENT_LOOP_IGNORE_GLIDE)

/mob/living/simple_animal/hostile/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(!ckey && !stat && search_objects < 3 && . > 0)//Not unconscious, and we don't ignore mobs
		if(search_objects)//Turn off item searching and ignore whatever item we were looking at, we're more concerned with fight or flight
			LoseTarget()
			LoseSearchObjects()
		if(AIStatus != AI_ON && AIStatus != AI_OFF)
			toggle_ai(AI_ON)
			FindTarget()
		else if(target != null && prob(40))//No more pulling a mob forever and having a second player attack it, it can switch targets now if it finds a more suitable one
			FindTarget()


/mob/living/simple_animal/hostile/proc/AttackingTarget(atom/attacked_target)
	in_melee = TRUE
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return FALSE //but more importantly return before attack_animal called
	var/result = target.attack_animal(src)
	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target, result)
	return result

/mob/living/simple_animal/hostile/proc/Aggro()
	vision_range = aggro_vision_range
	if(target && emote_taunt.len && prob(taunt_chance))
		manual_emote("[pick(emote_taunt)] at [target].")
		taunt_chance = max(taunt_chance-7,2)


/mob/living/simple_animal/hostile/proc/LoseAggro()
	stop_automated_movement = 0
	vision_range = initial(vision_range)
	taunt_chance = initial(taunt_chance)

/mob/living/simple_animal/hostile/proc/LoseTarget()
	GiveTarget(null)
	approaching_target = FALSE
	in_melee = FALSE
	SSmove_manager.stop_looping(src)
	LoseAggro()

//////////////END HOSTILE MOB TARGETTING AND AGGRESSION////////////

/mob/living/simple_animal/hostile/death(gibbed)
	LoseTarget()
	..(gibbed)

/mob/living/simple_animal/hostile/proc/summon_backup(distance, exact_faction_match)
	do_alert_animation()
	playsound(loc, 'sound/machines/chime.ogg', 50, TRUE, -1)
	var/atom/target_from = GET_TARGETS_FROM(src)
	for(var/mob/living/simple_animal/hostile/M in oview(distance, target_from))
		if(faction_check_mob(M, TRUE))
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(src,M.move_to_delay,M.minimum_distance)

/mob/living/simple_animal/hostile/proc/CheckFriendlyFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T in get_line(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return TRUE

/mob/living/simple_animal/hostile/proc/OpenFire(atom/A)
	if(CheckFriendlyFire(A))
		return
	if(!(simple_mob_flags & SILENCE_RANGED_MESSAGE))
		visible_message(span_danger("<b>[src]</b> [ranged_message] at [A]!"))


	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, .proc/Shoot, A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time


/mob/living/simple_animal/hostile/proc/Shoot(atom/targeted_atom)
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(QDELETED(targeted_atom) || targeted_atom == target_from.loc || targeted_atom == target_from )
		return
	var/turf/startloc = get_turf(target_from)
	face_atom(targeted_atom)
	if(casingtype)
		var/obj/item/ammo_casing/casing = new casingtype(startloc)
		playsound(src, projectilesound, 100, TRUE)
		casing.fire_casing(targeted_atom, src, null, null, null, ran_zone(), 0,  src)
	else if(projectiletype)
		var/obj/projectile/P = new projectiletype(startloc)
		playsound(src, projectilesound, 100, TRUE)
		P.starting = startloc
		P.firer = src
		P.fired_from = src
		P.yo = targeted_atom.y - startloc.y
		P.xo = targeted_atom.x - startloc.x
		if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
			newtonian_move(get_dir(targeted_atom, target_from))
		P.original = targeted_atom
		P.preparePixelProjectile(targeted_atom, src)
		P.fire()
		return P


/mob/living/simple_animal/hostile/proc/CanSmashTurfs(turf/T)
	return iswallturf(T) || ismineralturf(T)


/mob/living/simple_animal/hostile/Move(atom/newloc, dir , step_x , step_y)
	if(dodging && approaching_target && prob(dodge_prob) && moving_diagonally == 0 && isturf(loc) && isturf(newloc))
		return dodge(newloc,dir)
	else
		return ..()

/mob/living/simple_animal/hostile/proc/dodge(moving_to,move_direction)
	//Assuming we move towards the target we want to swerve toward them to get closer
	var/cdir = turn(move_direction,45)
	var/ccdir = turn(move_direction,-45)
	dodging = FALSE
	. = Move(get_step(loc,pick(cdir,ccdir)))
	if(!.)//Can't dodge there so we just carry on
		. = Move(moving_to,move_direction)
	dodging = TRUE

/mob/living/simple_animal/hostile/proc/DestroyObjectsInDirection(direction)
	var/atom/target_from = GET_TARGETS_FROM(src)
	var/turf/T = get_step(target_from, direction)
	if(QDELETED(T))
		return
	if(T.Adjacent(target_from))
		if(CanSmashTurfs(T))
			T.attack_animal(src)
			return
	for(var/obj/O in T.contents)
		if(!O.Adjacent(target_from))
			continue
		if((ismachinery(O) || isstructure(O)) && O.density && environment_smash >= ENVIRONMENT_SMASH_STRUCTURES && !O.IsObscured())
			O.attack_animal(src)
			return

/mob/living/simple_animal/hostile/proc/DestroyPathToTarget()
	if(environment_smash)
		EscapeConfinement()
		var/atom/target_from = GET_TARGETS_FROM(src)
		var/dir_to_target = get_dir(target_from, target)
		var/dir_list = list()
		if(ISDIAGONALDIR(dir_to_target)) //it's diagonal, so we need two directions to hit
			for(var/direction in GLOB.cardinals)
				if(direction & dir_to_target)
					dir_list += direction
		else
			dir_list += dir_to_target
		for(var/direction in dir_list) //now we hit all of the directions we got in this fashion, since it's the only directions we should actually need
			DestroyObjectsInDirection(direction)


/mob/living/simple_animal/hostile/proc/DestroySurroundings() // for use with megafauna destroying everything around them
	if(environment_smash)
		EscapeConfinement()
		for(var/dir in GLOB.cardinals)
			DestroyObjectsInDirection(dir)


/mob/living/simple_animal/hostile/proc/EscapeConfinement()
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(buckled)
		buckled.attack_animal(src)
	if(!isturf(target_from.loc) && target_from.loc != null)//Did someone put us in something?
		var/atom/A = target_from.loc
		A.attack_animal(src)//Bang on it till we get out

/mob/living/simple_animal/hostile/proc/FindHidden()
	if(istype(target.loc, /obj/structure/closet) || istype(target.loc, /obj/machinery/disposal) || istype(target.loc, /obj/machinery/sleeper))
		var/atom/A = target.loc
		var/atom/target_from = GET_TARGETS_FROM(src)
		Goto(A,move_to_delay,minimum_distance)
		if(A.Adjacent(target_from))
			A.attack_animal(src)
		return TRUE


/mob/living/simple_animal/hostile/RangedAttack(atom/A, modifiers) //Player firing
	if(ranged && ranged_cooldown <= world.time)
		GiveTarget(A)
		OpenFire(A)
	return ..()


////// AI Status ///////
/mob/living/simple_animal/hostile/proc/AICanContinue(list/possible_targets)
	switch(AIStatus)
		if(AI_ON)
			. = TRUE
		if(AI_IDLE)
			if(FindTarget(possible_targets, TRUE))
				. = TRUE
				toggle_ai(AI_ON) //Wake up for more than one Life() cycle.
			else
				return FALSE

/mob/living/simple_animal/hostile/proc/AIShouldSleep(list/possible_targets)
	return !FindTarget(possible_targets, TRUE)


///These two procs handle losing our target if we've failed to attack them for
///more than lose_patience_timeout deciseconds, which probably means we're stuck
/mob/living/simple_animal/hostile/proc/GainPatience()
	if(lose_patience_timeout)
		LosePatience()
		lose_patience_timer_id = addtimer(CALLBACK(src, .proc/LoseTarget), lose_patience_timeout, TIMER_STOPPABLE)


/mob/living/simple_animal/hostile/proc/LosePatience()
	deltimer(lose_patience_timer_id)


//These two procs handle losing and regaining search_objects when attacked by a mob
/mob/living/simple_animal/hostile/proc/LoseSearchObjects()
	search_objects = 0
	deltimer(search_objects_timer_id)
	search_objects_timer_id = addtimer(CALLBACK(src, .proc/RegainSearchObjects), search_objects_regain_time, TIMER_STOPPABLE)


/mob/living/simple_animal/hostile/proc/RegainSearchObjects(value)
	if(!value)
		value = initial(search_objects)
	search_objects = value

///check whether we should set our AIStatus to AI_DISTANCE_OFF, which requires that no client mobs we can see are within spatial grid cells
///intersecting a certain radius from us.
///returns TRUE if theres no way we can see any player mobs and should shut off
///returns FALSE if we shouldnt change AIStatus to AI_DISTANCE_OFF
/mob/living/simple_animal/hostile/proc/check_disable_proximity_conditions()
	if(AIStatus == AI_DISTANCE_OFF)
		return FALSE

	if(target)//if we see a target dont do shit until its nulled out
		return FALSE

	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return TRUE

	if(length(SSmobs.clients_by_zlevel[our_turf.z]))
		var/list/nearby_client_mobs = SSspatial_grid.orthogonal_range_search(src, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS, vision_range)
		for(var/mob/client_mob as anything in nearby_client_mobs)
			if(client_mob.invisibility <= see_invisible)
				return FALSE

		return TRUE
	else
		return TRUE

/mob/living/simple_animal/hostile/consider_wakeup()
	..()
	var/list/tlist
	var/turf/T = get_turf(src)

	if (!T)
		return FALSE

	if (AIStatus != AI_DISTANCE_OFF && check_disable_proximity_conditions())
		toggle_ai(AI_DISTANCE_OFF)
		return FALSE

	var/cheap_search = !is_station_level(T.z)
	if (cheap_search)
		tlist = ListTargetsLazy(T.z)
	else
		tlist = ListTargets()

	if(AIStatus == AI_IDLE && FindTarget(tlist, TRUE))
		if(cheap_search) //Try again with full effort
			FindTarget()
		toggle_ai(AI_ON)

///hostile mobs turn completely off if no players are close enough to save cpu resources. this does that by registering to
///every spatial grid cell in range for players entering it.
/mob/living/simple_animal/hostile/proc/register_to_players_getting_near(range)
	if(range <= 0)
		for(var/datum/spatial_grid_cell/old_cell as anything in listening_grid_cells)//unset old registrations
			UnregisterSignal(old_cell, SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_CLIENT_MOBS))

		UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		listening_grid_cells = null
		return FALSE

	//override because moving multiple times will proc this every time
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/on_moved_while_off, override = TRUE)
	var/list/grid_cells_in_range = SSspatial_grid.get_cells_in_range(src, range)

	if(listening_grid_cells)//we already have grid cells we're listening to, so find the difference and update
		var/list/newly_out_of_range_cells = listening_grid_cells - grid_cells_in_range

		for(var/datum/spatial_grid_cell/old_cell as anything in newly_out_of_range_cells)
			UnregisterSignal(old_cell, SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_CLIENT_MOBS))

	for(var/datum/spatial_grid_cell/intersecting_cell as anything in grid_cells_in_range)
		RegisterSignal(intersecting_cell, SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_CLIENT_MOBS), .proc/check_near_player, override = TRUE)

	listening_grid_cells = grid_cells_in_range
	if(!length(listening_grid_cells))
		listening_grid_cells = null

	return TRUE

///signal handler for SPATIAL_GRID_CELL_ENTERED(RECURSIVE_CONTENTS_CLIENT_MOBS) that checks whether we should wake up our ai for the player mob
///getting close to us.
/mob/living/simple_animal/hostile/proc/check_near_player(datum/spatial_grid_cell/entered_cell, atom/movable/entering_movable_with_client)
	SIGNAL_HANDLER

	if(see_invisible < entering_movable_with_client.invisibility)
		return//we cant see the player mob or its location by default, no sense turning on

	if(AIStatus == AI_DISTANCE_OFF)
		if(get_dist(get_turf(src), get_turf(entering_movable_with_client)) <= vision_range)
			toggle_ai(AI_ON)
		else
			toggle_ai(AI_IDLE)

	return

///signal handler that adjusts our spatial grid bounding box if we move while our ai is turned off.
/mob/living/simple_animal/hostile/proc/on_moved_while_off(datum/source)
	SIGNAL_HANDLER

	register_to_players_getting_near(vision_range)
	return

/mob/living/simple_animal/hostile/on_ai_distance_disabled(old_state)
	if(stop_life)//we're in the simulation fog of war so dont waste processing resources on us when it doesnt affect players
		SSsimple_mobs.processing_simple_mobs -= src//we can stay in current_run for 1 iteration. as a treat.

	register_to_players_getting_near(vision_range)

/mob/living/simple_animal/hostile/on_ai_disabled(old_state)
	if(old_state == AI_DISTANCE_OFF)//we arent on but we are no longer off due to no near players, so unset functionality coupled to AI_DISTANCE_OFF
		SSsimple_mobs.processing_simple_mobs |= src
		register_to_players_getting_near(0)

/mob/living/simple_animal/hostile/on_ai_enabled(old_state)
	if(old_state != AI_DISTANCE_OFF)
		return

	if(stop_life)
		SSsimple_mobs.processing_simple_mobs |= src

	register_to_players_getting_near(0)

/mob/living/simple_animal/hostile/proc/ListTargetsLazy(_Z)//Step 1, find out what we can see
	var/static/list/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/vehicle/sealed/mecha))
	. = list()
	for (var/mob/client_mob as anything in SSmobs.clients_by_zlevel[_Z])
		if (get_dist(client_mob, src) < vision_range)
			if (isturf(client_mob.loc))
				. += client_mob
			else if (client_mob.loc.type in hostile_machines)
				. += client_mob.loc

/mob/living/simple_animal/hostile/proc/get_targets_from()
	var/atom/target_from = targets_from.resolve()
	if(!target_from)
		targets_from = null
		return src
	return target_from

/mob/living/simple_animal/hostile/proc/handle_target_del(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = null
	LoseTarget()

/mob/living/simple_animal/hostile/proc/add_target(new_target)
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = new_target
	if(target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/handle_target_del)
