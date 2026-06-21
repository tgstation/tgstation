/// Keep away and launch skulls at every opportunity, prioritising injured allies
/datum/ai_controller/basic_controller/legion
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/legion/legion.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/legion,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_AGGRO_RANGE = 5, // Unobservant
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 4,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 6,
	)
	ai_movement = /datum/ai_movement/basic_avoidance

/// Chase and attack whatever we are targeting, if it's friendly we will heal them
/datum/ai_controller/basic_controller/legion_brood
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/legion/legion_brood.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/legion,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining/low_node_priority,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)
	ai_movement = /datum/ai_movement/basic_avoidance

/// Target nearby friendlies if they are hurt (and are not themselves Legions)
/datum/targeting_strategy/basic/legion

/datum/targeting_strategy/basic/legion/faction_check(datum/ai_controller/controller, mob/living/living_mob, mob/living/the_target)
	if (!living_mob.faction_check_atom(the_target, exact_match = check_factions_exactly))
		return FALSE
	if (istype(the_target, living_mob.type))
		return TRUE
	var/atom/created_by = living_mob.ai_controller.blackboard[BB_LEGION_BROOD_CREATOR]
	if (!QDELETED(created_by) && istype(the_target, created_by.type))
		return TRUE
	return the_target.stat == DEAD || the_target.health >= the_target.maxHealth

