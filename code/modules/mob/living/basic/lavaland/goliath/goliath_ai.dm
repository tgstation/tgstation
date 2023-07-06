/datum/ai_controller/basic_controller/goliath
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items/goliath(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath,
		///datum/ai_planning_subtree/find_food, // dig
	)

/datum/targetting_datum/basic/allow_items/goliath
	stat_attack = HARD_CRIT

/datum/ai_planning_subtree/basic_melee_attack_subtree/goliath
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/goliath

/// Go for the tentacles if they're available
/datum/ai_behavior/basic_melee_attack/goliath

/datum/ai_behavior/basic_melee_attack/goliath/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_GOLIATH_TENTACLES]
	if (using_action?.IsAvailable())
		finish_action(controller, succeeded = FALSE)
		return
	return ..()

/datum/ai_planning_subtree/targeted_mob_ability/goliath_tentacles
	ability_key = BB_GOLIATH_TENTACLES
