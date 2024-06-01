/datum/ai_controller/basic_controller/lobstrosity
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/allow_items,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_LOBSTROSITY_EXPLOIT_TRAITS = list(TRAIT_INCAPACITATED, TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT),
		BB_LOBSTROSITY_FINGER_LUST = 0
	)
	ai_traits = PAUSE_DURING_DO_AFTER

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/insect,
		/datum/ai_planning_subtree/hoard_fingers,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/lobster,
		/datum/ai_planning_subtree/flee_target/lobster,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/find_and_hunt_target/lobster_fishing,
		/datum/ai_planning_subtree/find_fingers,
	)

/datum/ai_planning_subtree/find_and_hunt_target/lobster_fishing
	target_key = BB_FISHING_TARGET
	hunt_targets = list(/turf/open/lava)
	hunting_behavior = /datum/ai_behavior/hunt_target/unarmed_attack_target/reset_target

/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/lobster

/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!isliving(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return ..()
	if (!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	if (!isnull(controller.blackboard[BB_LOBSTROSITY_TARGET_LIMB]))
		return
	var/mob/living/living_pawn = controller.pawn
	if (DOING_INTERACTION_WITH_TARGET(living_pawn, controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]))
		return
	return ..()

/datum/ai_behavior/basic_melee_attack/lobster

/datum/ai_behavior/basic_melee_attack/lobster/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/target = controller.blackboard[target_key]
	if (isnull(target) || !istype(target))
		return ..()
	var/is_vulnerable = FALSE
	for (var/trait in controller.blackboard[BB_LOBSTROSITY_EXPLOIT_TRAITS])
		if (!HAS_TRAIT(target, trait))
			continue
		is_vulnerable = TRUE
		break
	if (!is_vulnerable)
		controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, FALSE)
	if (!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		// We don't want to clear our target
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return ..()

/datum/ai_planning_subtree/flee_target/lobster
	flee_behaviour = /datum/ai_behavior/run_away_from_target/lobster

/datum/ai_planning_subtree/flee_target/lobster/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_TARGETED_ACTION]
	if (using_action?.IsAvailable())
		return
	return ..()

/datum/ai_behavior/run_away_from_target/lobster
	clear_failed_targets = FALSE

/datum/ai_behavior/run_away_from_target/lobster/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key)
	var/atom/target = controller.blackboard[target_key]
	if(isnull(target))
		return ..()

	for (var/trait in controller.blackboard[BB_LOBSTROSITY_EXPLOIT_TRAITS])
		if (!HAS_TRAIT(target, trait))
			continue
		controller.set_blackboard_key(BB_BASIC_MOB_STOP_FLEEING, TRUE)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/living/us = controller.pawn
	if (us.pulling == target)
		us.stop_pulling() // If we're running away from someone, best not to bring them with us

	return ..()

/// Don't use charge ability on an adjacent target, and make sure you're visible before you start
/datum/ai_planning_subtree/targeted_mob_ability/lobster
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/min_range

/datum/ai_planning_subtree/targeted_mob_ability/lobster/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target) || in_range(controller.pawn, target))
		return FALSE
	return ..()

/// Look for loose arms lying around
/datum/ai_planning_subtree/find_fingers
	/// Where do we store target limb data?
	var/target_key = BB_LOBSTROSITY_TARGET_LIMB
	/// What are we actually looking for?
	var/desired_type = /obj/item/bodypart/arm

/datum/ai_planning_subtree/find_fingers/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/find_and_set, target_key, desired_type)

/// If you see an arm, grab it and run
/datum/ai_planning_subtree/hoard_fingers
	/// Where do we store target limb data?
	var/target_key = BB_LOBSTROSITY_TARGET_LIMB

/datum/ai_planning_subtree/hoard_fingers/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return

	var/mob/living/living_pawn = controller.pawn
	if (living_pawn.pulling != current_target)
		controller.queue_behavior(/datum/ai_behavior/grab_fingers, target_key)
	else
		controller.queue_behavior(/datum/ai_behavior/hoard_fingers, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING

/// If our target is an arm then move over and drag it
/datum/ai_behavior/grab_fingers
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/grab_fingers/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return FALSE
	set_movement_target(controller, current_target)

/datum/ai_behavior/grab_fingers/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return AI_BEHAVIOR_DELAY
	var/mob/living/living_pawn = controller.pawn
	living_pawn.start_pulling(current_target)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// How far we'll try to go before eating an arm
#define FLEE_TO_RANGE 9
/// How many times we'll attempt to move before giving up
#define MAX_LOBSTROSITY_PATIENCE 15

/// If we are dragging an arm then run away until we are out of range and feast
/datum/ai_behavior/hoard_fingers
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// We store a counter at this key we increment on every movement until we are overwhelmed with hunger
	var/patience_key = BB_LOBSTROSITY_FINGER_LUST

/datum/ai_behavior/hoard_fingers/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(current_target))
		set_movement_target(controller, get_turf(controller.pawn))
		return
	var/perform_flags = target_step_away(controller, current_target, target_key)
	if (perform_flags & AI_BEHAVIOR_SUCCEEDED)
		finish_action(controller, TRUE, target_key)
	else if(perform_flags & AI_BEHAVIOR_FAILED)
		finish_action(controller, FALSE, target_key)

/// Find the next step to take away from the current target
/datum/ai_behavior/hoard_fingers/proc/target_step_away(datum/ai_controller/controller, atom/current_target, target_key)
	var/turf/next_step = get_step_away(controller.pawn, current_target)
	if (!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
		set_movement_target(controller, next_step)
		return NONE
	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(controller.pawn, next_step)
	all_dirs -= get_dir(controller.pawn, current_target)
	shuffle_inplace(all_dirs)
	for (var/dir in all_dirs)
		next_step = get_step(controller.pawn, dir)
		if (!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
			set_movement_target(controller, next_step)
			return NONE
	return AI_BEHAVIOR_FAILED

/datum/ai_behavior/hoard_fingers/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	var/current_patience = controller.blackboard[patience_key] + 1
	if (current_patience >= MAX_LOBSTROSITY_PATIENCE)
		if(eat_fingers(controller, target_key))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	controller.set_blackboard_key(patience_key, current_patience)
	var/mob/living/living_pawn = controller.pawn
	if (isnull(living_pawn.pulling))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(current_target) || !can_see(controller.pawn, current_target, FLEE_TO_RANGE))
		if(eat_fingers(controller, target_key))
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	if(target_step_away(controller, current_target, target_key))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

/// Finally consume those delicious digits
/datum/ai_behavior/hoard_fingers/proc/eat_fingers(datum/ai_controller/controller, target_key)
	var/mob/living/basic/living_pawn = controller.pawn
	var/atom/fingers = controller.blackboard[target_key]
	if (QDELETED(fingers) || living_pawn.pulling != fingers)
		return AI_BEHAVIOR_FAILED
	living_pawn.melee_attack(fingers)
	return AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/hoard_fingers/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.set_blackboard_key(patience_key, 0)
	controller.clear_blackboard_key(target_key)
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)

#undef FLEE_TO_RANGE
#undef MAX_LOBSTROSITY_PATIENCE
