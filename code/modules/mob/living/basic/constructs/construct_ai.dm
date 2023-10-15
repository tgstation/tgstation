/// Artificers
/datum/ai_controller/basic_controller/artificer
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/attack_wounded_only/same_faction/construct,
		BB_FLEE_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
	)

/// Targetting datum that will only allow mobs that constructs can heal.
/datum/targetting_datum/basic/attack_wounded_only/same_faction/construct

/datum/targetting_datum/basic/attack_wounded_only/same_faction/construct/can_attack(mob/living/living_mob, atom/the_target, vision_range, check_faction = TRUE)
	. = ..()
	if(isconstruct(the_target) || istype(the_target, /mob/living/simple_animal/shade))
		return .
	return FALSE
