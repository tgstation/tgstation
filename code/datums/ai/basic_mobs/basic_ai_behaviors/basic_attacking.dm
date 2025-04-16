/// Amount of time to wait before executing attack if not specified
#define DEFAULT_ATTACK_DELAY (0.4 SECONDS)

/datum/ai_behavior/basic_melee_attack
	action_cooldown = 0.2 SECONDS // We gotta check unfortunately often because we're in a race condition with nextmove
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	///do we finish this action after hitting once?
	var/terminate_after_action = FALSE

/datum/ai_behavior/basic_melee_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!controller.blackboard[targeting_strategy_key])
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")
	//Hiding location is priority
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE

	set_movement_target(controller, target)

/datum/ai_behavior/basic_melee_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/target = controller.blackboard[target_key]
	if (isnull(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if (!controller.pawn.CanReach(target))
		controller.clear_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER)
		return AI_BEHAVIOR_INSTANT

	var/can_attack_time = controller.blackboard[BB_BASIC_MOB_MELEE_COOLDOWN_TIMER]
	if (isnull(can_attack_time))
		var/blackboard_delay = controller.blackboard[BB_BASIC_MOB_MELEE_DELAY]
		var/attack_delay = isnull(blackboard_delay) ? DEFAULT_ATTACK_DELAY : blackboard_delay
		controller.set_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER, world.time + attack_delay)
		return AI_BEHAVIOR_INSTANT
	if (can_attack_time > world.time)
		return AI_BEHAVIOR_INSTANT

	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return AI_BEHAVIOR_INSTANT

	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!targeting_strategy.can_attack(controller.pawn, target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/hiding_target = targeting_strategy.find_hidden_mobs(controller.pawn, target) //If this is valid, theyre hidden in something!

	controller.set_blackboard_key(hiding_location_key, hiding_target)

	var/atom/final_target = hiding_target || target
	controller.ai_interact(target = final_target, combat_mode = TRUE)
	if(terminate_after_action)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY

/datum/ai_behavior/basic_melee_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.clear_blackboard_key(BB_BASIC_MOB_MELEE_COOLDOWN_TIMER)
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_melee_attack/interact_once
	terminate_after_action = TRUE

/datum/ai_behavior/basic_melee_attack/interact_once/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_ranged_attack
	action_cooldown = 0.6 SECONDS
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM
	required_distance = 3
	/// range we will try chasing the target before giving up
	var/chase_range = 9
	///do we care about avoiding friendly fire?
	var/avoid_friendly_fire =  FALSE

/datum/ai_behavior/basic_ranged_attack/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(HAS_TRAIT(controller.pawn, TRAIT_HANDS_BLOCKED))
		return FALSE
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/basic_ranged_attack/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/basic/basic_mob = controller.pawn
	//targeting strategy will kill the action if not real anymore
	var/atom/target = controller.blackboard[target_key]
	var/datum/targeting_strategy/targeting_strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])

	if(!targeting_strategy.can_attack(basic_mob, target, chase_range))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/atom/hiding_target = targeting_strategy.find_hidden_mobs(basic_mob, target) //If this is valid, theyre hidden in something!
	var/atom/final_target = hiding_target ? hiding_target : target

	if(!can_see(basic_mob, final_target, required_distance))
		return AI_BEHAVIOR_INSTANT

	if(avoid_friendly_fire && check_friendly_in_path(basic_mob, target, targeting_strategy))
		adjust_position(basic_mob, target)
		return AI_BEHAVIOR_DELAY

	controller.set_blackboard_key(hiding_location_key, hiding_target)
	basic_mob.RangedAttack(final_target)
	return AI_BEHAVIOR_DELAY //only start the cooldown when the shot is shot

/datum/ai_behavior/basic_ranged_attack/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/basic_ranged_attack/proc/check_friendly_in_path(mob/living/source, atom/target, datum/targeting_strategy/targeting_strategy)
	var/list/turfs_list = calculate_trajectory(source, target)
	for(var/turf/possible_turf as anything in turfs_list)

		for(var/mob/living/potential_friend in possible_turf)
			if(!targeting_strategy.can_attack(source, potential_friend))
				return TRUE

	return FALSE

/datum/ai_behavior/basic_ranged_attack/proc/adjust_position(mob/living/living_pawn, atom/target)
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

/datum/ai_behavior/basic_ranged_attack/proc/calculate_trajectory(mob/living/source , atom/target)
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

/datum/ai_behavior/basic_ranged_attack/avoid_friendly_fire
	avoid_friendly_fire = TRUE

#undef DEFAULT_ATTACK_DELAY
