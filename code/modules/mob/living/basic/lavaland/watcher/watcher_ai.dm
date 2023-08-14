/datum/ai_controller/basic_controller/watcher
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability/gaze,
		/datum/ai_planning_subtree/targeted_mob_ability/overwatch,
		/datum/ai_planning_subtree/ranged_skirmish,
		/datum/ai_planning_subtree/keep_away,
	)

/datum/ai_planning_subtree/targeted_mob_ability/overwatch
	ability_key = BB_WATCHER_OVERWATCH

/datum/ai_planning_subtree/targeted_mob_ability/overwatch/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if (!isliving(target)) // Do not overwatch at items
		return
	return ..()

/datum/ai_planning_subtree/use_mob_ability/gaze
	ability_key = BB_WATCHER_GAZE
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/gaze/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/watcher = controller.pawn
	if (watcher.health > watcher.maxHealth / 1.5) // When we're a little hurt
		return
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(target))
		return // Don't do this if there's nothing hostile around
	return ..()

/datum/ai_planning_subtree/ranged_skirmish/watcher
	attack_behavior = /datum/ai_behavior/ranged_skirmish/watcher

/datum/ai_behavior/ranged_skirmish/watcher
	min_range = 0
