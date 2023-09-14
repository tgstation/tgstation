/**
 * Slap someone who is nearby, line up with target, blast with a beam
 */
/datum/ai_controller/basic_controller/brimdemon
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/no_target
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_adjacent_target,
		/datum/ai_planning_subtree/move_to_cardinal/brimdemon,
		/datum/ai_planning_subtree/targeted_mob_ability/brimbeam,
	)

/datum/ai_planning_subtree/move_to_cardinal/brimdemon
	move_behaviour = /datum/ai_behavior/move_to_cardinal/brimdemon

/datum/ai_behavior/move_to_cardinal/brimdemon
	minimum_distance = 2

/datum/ai_planning_subtree/targeted_mob_ability/brimbeam
	/// Don't shoot if too far away
	var/max_target_distance = 9

/datum/ai_planning_subtree/targeted_mob_ability/brimbeam/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if (QDELETED(target) || !(get_dir(controller.pawn, target) in GLOB.cardinals) || get_dist(controller.pawn, target) > max_target_distance)
		return
	return ..()
