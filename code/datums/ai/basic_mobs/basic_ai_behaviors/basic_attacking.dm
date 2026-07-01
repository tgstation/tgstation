/// Amount of time to wait before executing attack if not specified
#define DEFAULT_ATTACK_DELAY (0.4 SECONDS)

/// Perform a melee attack on the target specified.
/datum/bt_node/ai_behavior/basic_melee_attack
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key

/datum/bt_node/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller)
	. = ..()


	if(!ispath(targeting_strategy))
		targeting_strategy = controller.blackboard[targeting_strategy]

	if(!targeting_strategy)
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

/datum/bt_node/ai_behavior/basic_melee_attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/atom/target = controller.blackboard[target_key]
	if (isnull(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if (!target.IsReachableBy(controller.pawn))
		controller.clear_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/can_attack_time = controller.blackboard[BB_BASIC_MOB_MELEE_COOLDOWN_TIMER]
	if (isnull(can_attack_time))
		var/blackboard_delay = controller.blackboard[BB_BASIC_MOB_MELEE_DELAY]
		var/attack_delay = isnull(blackboard_delay) ? DEFAULT_ATTACK_DELAY : blackboard_delay
		controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time + attack_delay)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if (can_attack_time > world.time)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(targeting_strategy)
	if(!strategy.is_valid_target(controller.pawn, target))
		controller.clear_blackboard_key(target_key)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/hiding_target = strategy.find_hidden_mobs(controller.pawn, target) //If this is valid, theyre hidden in something!

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	var/atom/final_target = hiding_target || target
	INVOKE_ASYNC(controller, TYPE_PROC_REF(/datum/ai_controller, ai_interact), final_target, TRUE)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Single-hit variant: terminates after one successful attack and always clears the target key.
/datum/bt_node/ai_behavior/basic_melee_attack/interact_once

/datum/bt_node/ai_behavior/basic_melee_attack/interact_once/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)

//Basic ranged attack behavior
/datum/bt_node/ai_behavior/basic_ranged_attack
	var/target_key
	var/targeting_strategy = BB_TARGETING_STRATEGY
	var/hiding_location_key
	time_between_perform = 0.6 SECONDS
	/// Max range at which we can fire. Make sure your movement actually gets you this close please
	var/max_range = 9
	/// Avoid shooting through friendlies.
	var/avoid_friendly_fire = FALSE

/datum/bt_node/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller)
	. = ..()
	if(HAS_TRAIT(controller.pawn, TRAIT_HANDS_BLOCKED))
		return FALSE
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return TRUE

/datum/bt_node/ai_behavior/basic_ranged_attack/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/basic_mob = controller.pawn
	var/atom/target = controller.blackboard[target_key]

	if(!ispath(targeting_strategy))
		targeting_strategy = controller.blackboard[targeting_strategy]

	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(targeting_strategy)

	var/atom/hiding_target = strategy.find_hidden_mobs(basic_mob, target)
	var/atom/final_target = hiding_target ? hiding_target : target
	controller.set_blackboard_key(hiding_location_key, hiding_target)

	if(!can_see(basic_mob, final_target, max_range))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	if(avoid_friendly_fire && check_friendly_in_path(basic_mob, target, strategy))
		adjust_position(basic_mob, target)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	basic_mob.RangedAttack(final_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/basic_ranged_attack/proc/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)
	var/list/turfs_list = calculate_trajectory(source, target)
	for(var/turf/possible_turf as anything in turfs_list)
		for(var/mob/living/potential_friend in possible_turf)
			if(!targeting_strategy.is_valid_target(source, potential_friend))
				return TRUE
	return FALSE

/datum/bt_node/ai_behavior/basic_ranged_attack/proc/adjust_position(mob/living/living_pawn, atom/target)
	var/turf/our_turf = get_turf(living_pawn)
	var/list/possible_turfs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/target_turf = get_step(our_turf, direction)
		if(isnull(target_turf))
			continue
		if(target_turf.is_blocked_turf() || get_dist(target_turf, target) > get_dist(living_pawn, target))
			continue
		possible_turfs += target_turf
	if(!length(possible_turfs))
		return
	var/turf/picked_turf = get_closest_atom(/turf, possible_turfs, target)
	step(living_pawn, get_dir(living_pawn, picked_turf))

/datum/bt_node/ai_behavior/basic_ranged_attack/proc/calculate_trajectory(mob/living/source, atom/target)
	var/list/turf_list = get_line(source, target)
	var/list_length = length(turf_list) - 1
	for(var/i in 1 to list_length)
		var/turf/current_turf = turf_list[i]
		var/turf/next_turf = turf_list[i+1]
		var/direction_to_turf = get_dir(current_turf, next_turf)
		if(!ISDIAGONALDIR(direction_to_turf))
			continue
		for(var/cardinal_direction in GLOB.cardinals)
			if(cardinal_direction & direction_to_turf)
				turf_list += get_step(current_turf, cardinal_direction)
	turf_list -= get_turf(source)
	turf_list -= get_turf(target)
	return turf_list

/datum/bt_node/ai_behavior/basic_ranged_attack/avoid_friendly_fire
	avoid_friendly_fire = TRUE

#undef DEFAULT_ATTACK_DELAY
