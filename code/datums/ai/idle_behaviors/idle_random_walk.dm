/datum/idle_behavior/idle_random_walk
	///Chance that the mob random walks per second
	var/walk_chance = 25

/datum/idle_behavior/idle_random_walk/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(LAZYLEN(living_pawn.do_afters))
		return FALSE

	var/actual_chance = controller.blackboard[BB_BASIC_MOB_IDLE_WALK_CHANCE] || walk_chance
	if(SPT_PROB(actual_chance, seconds_per_tick) && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby)
		var/move_dir = pick(GLOB.alldirs)
		var/turf/destination_turf = get_step(living_pawn, move_dir)
		if(!destination_turf?.can_cross_safely(living_pawn))
			return FALSE
		living_pawn.Move(destination_turf, move_dir)
	return TRUE

/datum/idle_behavior/idle_random_walk/less_walking
	walk_chance = 10


/// Only walk if we are not on the target's location
/datum/idle_behavior/idle_random_walk/not_while_on_target
	///What is the spot we have to stand on?
	var/target_key

/datum/idle_behavior/idle_random_walk/not_while_on_target/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]

	//Don't move, if we are are already standing on it
	if(!QDELETED(target) && ((isturf(target) && controller.pawn.loc == target) || (target.loc == controller.pawn.loc)))
		return

	return ..()

/// walk randomly however stick near a target
/datum/idle_behavior/walk_near_target
	/// chance to walk
	var/walk_chance = 25
	/// distance we are to target
	var/minimum_distance = 20
	/// key that holds target
	var/target_key

/datum/idle_behavior/walk_near_target/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	if(LAZYLEN(living_pawn.do_afters))
		return

	if(!SPT_PROB(walk_chance, seconds_per_tick) || !(living_pawn.mobility_flags & MOBILITY_MOVE) || !isturf(living_pawn.loc) || living_pawn.pulledby)
		return

	var/atom/target = controller.blackboard[target_key]
	var/distance = get_dist(target, living_pawn)
	if(isnull(target) || distance > minimum_distance) //if we are too far away from target, just walk randomly
		var/move_dir = pick(GLOB.alldirs)
		living_pawn.Move(get_step(living_pawn, move_dir), move_dir)
		return

	var/list/possible_turfs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/possible_step = get_step(living_pawn, direction)
		if(get_dist(possible_step, target) > minimum_distance)
			continue
		if(possible_step.is_blocked_turf() || !possible_step.can_cross_safely(living_pawn))
			continue
		possible_turfs += possible_step

	if(!length(possible_turfs))
		return

	var/turf/picked_turf = pick(possible_turfs)

	living_pawn.Move(picked_turf, get_dir(living_pawn, picked_turf))

// BT-native idle wander leaves.
/datum/bt_node/ai_behavior/idle_random_walk
	/// Chance that the mob random walks per second.
	var/walk_chance = 25

/datum/bt_node/ai_behavior/idle_random_walk/proc/can_move(mob/living/living_pawn)
	return living_pawn && (living_pawn.mobility_flags & MOBILITY_MOVE) && isturf(living_pawn.loc) && !living_pawn.pulledby

/datum/bt_node/ai_behavior/idle_random_walk/proc/try_random_step(mob/living/living_pawn, seconds_per_tick, step_walk_chance)
	if(LAZYLEN(living_pawn.do_afters))
		return FALSE

	if(!SPT_PROB(step_walk_chance, seconds_per_tick) || !can_move(living_pawn))
		return FALSE

	var/move_dir = pick(GLOB.alldirs)
	var/turf/destination_turf = get_step(living_pawn, move_dir)
	if(!destination_turf?.can_cross_safely(living_pawn))
		return FALSE

	living_pawn.Move(destination_turf, move_dir)
	return TRUE

/datum/bt_node/ai_behavior/idle_random_walk/proc/try_near_target_step(mob/living/living_pawn, atom/target, seconds_per_tick, step_walk_chance, minimum_distance)
	if(isnull(target) || !can_move(living_pawn) || LAZYLEN(living_pawn.do_afters))
		return FALSE

	if(!SPT_PROB(step_walk_chance, seconds_per_tick))
		return FALSE

	var/distance = get_dist(target, living_pawn)
	if(distance > minimum_distance)
		return try_random_step(living_pawn, seconds_per_tick, step_walk_chance)

	var/list/possible_turfs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/possible_step = get_step(living_pawn, direction)
		if(get_dist(possible_step, target) > minimum_distance)
			continue
		if(possible_step.is_blocked_turf() || !possible_step.can_cross_safely(living_pawn))
			continue
		possible_turfs += possible_step

	if(!length(possible_turfs))
		return FALSE

	var/turf/picked_turf = pick(possible_turfs)
	living_pawn.Move(picked_turf, get_dir(living_pawn, picked_turf))
	return TRUE

/datum/bt_node/ai_behavior/idle_random_walk/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	try_random_step(living_pawn, seconds_per_tick, walk_chance)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED


// Only walk if we don't have a target.
/datum/bt_node/ai_behavior/idle_random_walk/no_target
	/// Where do we look for a target?
	var/target_key = BB_CURRENT_TARGET

/datum/bt_node/ai_behavior/idle_random_walk/no_target/perform(seconds_per_tick, datum/ai_controller/controller)
	if(controller.blackboard_key_exists(target_key))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

// Only walk if we are not on the target's location.
/datum/bt_node/ai_behavior/idle_random_walk/not_while_on_target
	/// What is the spot we have to stand on?
	var/target_key

/datum/bt_node/ai_behavior/idle_random_walk/not_while_on_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if(!QDELETED(target) && ((isturf(target) && controller.pawn.loc == target) || (target.loc == controller.pawn.loc)))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

// Walk more when healthy and on rust (explore for more), or damaged and off rust (seek healing rust).
/datum/bt_node/ai_behavior/idle_random_walk/rust

/datum/bt_node/ai_behavior/idle_random_walk/rust/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/turf/my_turf = get_turf(living_pawn)
	var/on_rust = HAS_TRAIT(my_turf, TRAIT_RUSTY)
	var/damaged = living_pawn.health < living_pawn.maxHealth
	try_random_step(living_pawn, seconds_per_tick, (on_rust == damaged) ? 10 : 50)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

// Walk randomly, but stay near a target when possible.
/datum/bt_node/ai_behavior/idle_random_walk/walk_near_target
	/// Distance we are allowed to stay from the target.
	var/minimum_distance = 20
	/// Key that holds target.
	var/target_key

/datum/bt_node/ai_behavior/idle_random_walk/walk_near_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		target = null

	if(!can_move(living_pawn) || LAZYLEN(living_pawn.do_afters) || !SPT_PROB(walk_chance, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(isnull(target) || get_dist(target, living_pawn) > minimum_distance)
		try_random_step(living_pawn, seconds_per_tick, walk_chance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	if(!try_near_target_step(living_pawn, target, seconds_per_tick, walk_chance, minimum_distance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
