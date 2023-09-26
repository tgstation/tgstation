/// Keep away and launch skulls at every opportunity, prioritising injured allies
/datum/ai_controller/basic_controller/legion
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/attack_until_dead/legion,
		BB_BASIC_MOB_FLEEING = TRUE,
		BB_AGGRO_RANGE = 5, // Unobservant
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability,
		/datum/ai_planning_subtree/flee_target/legion,
		// random speech legion
	)

/// Chase and attack whatever we are targetting, if it's friendly we will heal them
/datum/ai_controller/basic_controller/legion_brood
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/attack_until_dead/legion,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Target nearby friendlies if they are hurt (and are not themselves Legions)
/datum/targetting_datum/basic/attack_until_dead/legion

/datum/targetting_datum/basic/attack_until_dead/legion/faction_check(mob/living/living_mob, mob/living/the_target)
	if (!living_mob.faction_check_mob(the_target, exact_match = check_factions_exactly))
		return FALSE
	if (istype(the_target, /mob/living/basic/mining/legion))
		return TRUE
	return the_target.stat == DEAD || the_target.health >= the_target.maxHealth

/// Don't run away from friendlies
/datum/ai_planning_subtree/flee_target/legion

/datum/ai_planning_subtree/flee_target/legion/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[target_key]
	if (QDELETED(target) || target.faction_check_mob(controller.pawn))
		return // Only flee if we have a hostile target
	return ..()
