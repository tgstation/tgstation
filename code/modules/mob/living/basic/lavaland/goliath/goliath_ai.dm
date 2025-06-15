/// We won't use tentacles unless we have had the same target for this long
#define MIN_TIME_TO_TENTACLE 3 SECONDS

/datum/ai_controller/basic_controller/goliath
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath,
		/datum/ai_planning_subtree/goliath_find_diggable_turf,
		/datum/ai_planning_subtree/goliath_dig,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath
	operational_datums = list(/datum/component/ai_target_timer)
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/goliath

/// Go for the tentacles if they're available
/datum/ai_behavior/basic_melee_attack/goliath

/datum/ai_behavior/basic_melee_attack/goliath/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, health_ratio_key)
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < MIN_TIME_TO_TENTACLE)
		return ..()
	var/mob/living/target = controller.blackboard[target_key]
	// Interrupt attack chain to use tentacles, unless the target is already tentacled
	if (ismecha(target) || (isliving(target) && !target.has_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled)))
		var/datum/action/cooldown/using_action = controller.blackboard[BB_GOLIATH_TENTACLES]
		if (using_action?.IsAvailable())
			return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles
	ability_key = BB_GOLIATH_TENTACLES
	operational_datums = list(/datum/component/ai_target_timer)

/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if (!(isliving(target) || ismecha(target)) || (isliving(target) && target.has_status_effect(/datum/status_effect/incapacitating/stun/goliath_tentacled)))
		return // Target can be an item or already grabbed, we don't want to tentacle those
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < MIN_TIME_TO_TENTACLE)
		return // We need to spend some time acquiring our target first
	return ..()

/// If we got nothing better to do, find a turf we can search for tasty roots and such
/datum/ai_planning_subtree/goliath_find_diggable_turf

/datum/ai_planning_subtree/goliath_find_diggable_turf/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	controller.queue_behavior(/datum/ai_behavior/goliath_find_diggable_turf)

/datum/ai_behavior/goliath_find_diggable_turf
	action_cooldown = 2 SECONDS
	/// Where do we store the target data
	var/target_key = BB_GOLIATH_HOLE_TARGET
	/// How far do we look for turfs?
	var/scan_range = 3

/datum/ai_behavior/goliath_find_diggable_turf/perform(seconds_per_tick, datum/ai_controller/controller)
	var/turf/target_turf = controller.blackboard[target_key]
	if (is_valid_turf(target_turf))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/pawn = controller.pawn
	var/list/nearby_turfs = RANGE_TURFS(scan_range, pawn)
	var/turf/check_turf = pick(nearby_turfs) // This isn't an efficient search algorithm but we don't need it to be
	if (!is_valid_turf(check_turf))
		// Otherwise they won't perform idle wanderin
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(target_key, check_turf)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Return true if this is a turf we can dig
/datum/ai_behavior/goliath_find_diggable_turf/proc/is_valid_turf(turf/check_turf)
	if (!isasteroidturf(check_turf))
		return FALSE
	var/turf/open/misc/asteroid/floor = check_turf
	return !floor.dug

/datum/ai_planning_subtree/goliath_dig
	/// Where did we store the target data
	var/target_key = BB_GOLIATH_HOLE_TARGET

/datum/ai_planning_subtree/goliath_dig/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!controller.blackboard_key_exists(target_key))
		return
	controller.queue_behavior(/datum/ai_behavior/goliath_dig, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/// If we got nothing better to do, dig a little hole
/datum/ai_behavior/goliath_dig
	action_cooldown = 3 MINUTES
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/goliath_dig/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/turf/target_turf = controller.blackboard[target_key]
	if (QDELETED(target_turf))
		return
	set_movement_target(controller, target_turf)

/datum/ai_behavior/goliath_dig/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/turf/target_turf = controller.blackboard[target_key]
	var/mob/living/basic/basic_mob = controller.pawn
	if(!basic_mob.CanReach(target_turf))
		return AI_BEHAVIOR_DELAY
	basic_mob.melee_attack(target_turf)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/goliath_dig/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

#undef MIN_TIME_TO_TENTACLE
