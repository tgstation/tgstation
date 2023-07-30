/datum/ai_controller/basic_controller/lobstrosity
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_LOBSTROSITY_EXPLOIT_TRAITS = list(TRAIT_INCAPACITATED, TRAIT_FLOORED, TRAIT_IMMOBILIZED, TRAIT_KNOCKEDOUT),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/lobster,
		/datum/ai_planning_subtree/flee_target/lobster,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/lobster

/datum/ai_planning_subtree/basic_melee_attack_subtree/lobster/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (controller.blackboard[BB_BASIC_MOB_FLEEING])
		return
	return ..()

/datum/ai_behavior/basic_melee_attack/lobster
	action_cooldown = 1 SECONDS

/datum/ai_behavior/basic_melee_attack/lobster/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/is_vulnerable = FALSE
	var/atom/target = controller.blackboard[target_key]
	for (var/trait in controller.blackboard[BB_LOBSTROSITY_EXPLOIT_TRAITS])
		if (!HAS_TRAIT(target, trait))
			continue
		is_vulnerable = TRUE
		break
	if (!is_vulnerable)
		controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, TRUE)
	if (controller.blackboard[BB_BASIC_MOB_FLEEING])
		finish_action(controller = controller, succeeded = TRUE, target_key = target_key) // We don't want to clear our target
		return
	return ..()

/datum/ai_planning_subtree/flee_target/lobster
	flee_behaviour = /datum/ai_behavior/run_away_from_target/lobster

/datum/ai_behavior/run_away_from_target/lobster
	clear_failed_targets = FALSE

/datum/ai_behavior/run_away_from_target/lobster/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key)
	var/atom/target = controller.blackboard[target_key]
	for (var/trait in controller.blackboard[BB_LOBSTROSITY_EXPLOIT_TRAITS])
		if (!HAS_TRAIT(target, trait))
			continue
		controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, FALSE)
		finish_action(controller, succeeded = FALSE)
		return

	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/lobster
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/in_range
