/**
 * Artificers
 *
 * Artificers will seek out and heal the most wounded construct or shade they can see.
 * If there is no one to heal, they will run away from any non-allied mobs.
 */
/datum/ai_controller/basic_controller/artificer
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/same_faction/construct,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_WOUNDED_ONLY = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
	)

/**
 * Juggernauts
 *
 * Juggernauts slowly walk toward non-allied mobs and pummel them to death.
 */
/datum/ai_controller/basic_controller/juggernaut
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/**
 * Proteons
 *
 * Proteons perform cowardly hit-and-run attacks, fleeing melee when struck but returning to fight again.
 */
/datum/ai_controller/basic_controller/proteon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/target_retaliate/to_flee,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/**
 * Wraiths
 *
 * Wraiths seek out the most injured non-allied mob to beat to death.
 */
/datum/ai_controller/basic_controller/wraith
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_wounded_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/// Targeting strategy that will only allow mobs that constructs can heal.
/datum/targeting_strategy/basic/same_faction/construct
	target_wounded_key = BB_TARGET_WOUNDED_ONLY

/datum/targeting_strategy/basic/same_faction/construct/can_attack(mob/living/living_mob, atom/the_target, vision_range, check_faction = TRUE)
	if(isconstruct(the_target) || istype(the_target, /mob/living/basic/shade))
		return ..()
	return FALSE
