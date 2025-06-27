/datum/ai_controller/basic_controller/watcher
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/check_faction,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance,
		/datum/ai_planning_subtree/use_mob_ability/gaze,
		/datum/ai_planning_subtree/ranged_skirmish/watcher,
	)

/datum/ai_planning_subtree/use_mob_ability/gaze
	finish_planning = TRUE

/datum/ai_planning_subtree/use_mob_ability/gaze/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (!isliving(target))
		return // Don't do this if there's nothing hostile around or if our target is a mech
	var/time_on_target = controller.blackboard[BB_BASIC_MOB_HAS_TARGET_TIME] || 0
	if (time_on_target < 5 SECONDS)
		return // We need to spend some time acquiring our target first
	return ..()

/datum/ai_planning_subtree/ranged_skirmish/watcher
	min_range = 0

/datum/ai_planning_subtree/ranged_skirmish/watcher/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (QDELETED(target) || HAS_TRAIT(target, TRAIT_OVERWATCHED))
		return // Don't bully people who are playing red light green light
	return ..()
