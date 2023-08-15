/datum/ai_controller/basic_controller/watcher
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/use_mob_ability/gaze,
		/datum/ai_planning_subtree/targeted_mob_ability/overwatch,
		/datum/ai_planning_subtree/ranged_skirmish/watcher,
		/datum/ai_planning_subtree/maintain_distance,
	)

/datum/ai_planning_subtree/targeted_mob_ability/overwatch
	ability_key = BB_WATCHER_OVERWATCH

/datum/ai_planning_subtree/targeted_mob_ability/overwatch/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target) || HAS_TRAIT(target, TRAIT_OVERWATCH_IMMUNE))
		return // We should probably let miners move sometimes
	return ..()

/datum/ai_planning_subtree/use_mob_ability/gaze
	ability_key = BB_WATCHER_GAZE
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/gaze/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/watcher = controller.pawn
	if (watcher.health > watcher.maxHealth * 0.66) // When we're a little hurt
		return
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (!isliving(target))
		return // Don't do this if there's nothing hostile around or if our target is a mech
	return ..()

/datum/ai_planning_subtree/ranged_skirmish/watcher
	attack_behavior = /datum/ai_behavior/ranged_skirmish/watcher

/datum/ai_planning_subtree/ranged_skirmish/watcher/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(target) || HAS_TRAIT(target, TRAIT_OVERWATCHED))
		return // Don't bully people who are playing red light green light
	return ..()

/datum/ai_behavior/ranged_skirmish/watcher
	min_range = 0
