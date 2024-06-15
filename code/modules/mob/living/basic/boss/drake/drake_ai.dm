/datum/ai_controller/basic_controller/drake
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/megafauna,
		BB_TARGET_MINIMUM_STAT = DEAD,
		BB_ANGER_MODIFIER = 0,
		BB_AGGRO_RANGE = 5, //18 if aggroed
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/ranged_skirmish/drake,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/ranged_skirmish/drake
	operational_datums = null // uses its RangedAttack proc for this
	min_range = 0

/datum/ai_planning_subtree/ranged_skirmish/drake/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if (!istype(target))
		return
	if(target.stat != DEAD)
		return ..()
