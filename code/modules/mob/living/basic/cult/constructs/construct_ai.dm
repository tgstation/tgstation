/**
 * Artificers
 *
 * Artificers will seek out and heal the most wounded construct or shade they can see.
 * If there is no one to heal, they will run away from any non-allied mobs.
 */
/datum/ai_controller/basic_controller/artificer
	behavior_tree_json = "code/modules/mob/living/basic/cult/constructs/artificer.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/same_faction/construct,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_WOUNDED_ONLY = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/**
 * Juggernauts
 *
 * Juggernauts slowly walk toward non-allied mobs and pummel them to death.
 */
/datum/ai_controller/basic_controller/juggernaut
	behavior_tree_json = "code/modules/mob/living/basic/cult/constructs/juggernaut.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/**
 * Proteons
 *
 * Proteons perform cowardly hit-and-run attacks, fleeing melee when struck but returning to fight again.
 */
/datum/ai_controller/basic_controller/proteon
	behavior_tree_json = "code/modules/mob/living/basic/cult/constructs/proteon.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/**
 * Wraiths
 *
 * Wraiths seek out the most injured non-allied mob to beat to death.
 */
/datum/ai_controller/basic_controller/wraith
	behavior_tree_json = "code/modules/mob/living/basic/cult/constructs/wraith.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

/// Targeting strategy that will only allow mobs that constructs can heal.
/datum/targeting_strategy/basic/same_faction/construct
	target_wounded_key = BB_TARGET_WOUNDED_ONLY

/datum/targeting_strategy/basic/same_faction/construct/is_valid_target(mob/living/living_mob, atom/the_target, vision_range, check_faction = TRUE)
	if(isconstruct(the_target) || istype(the_target, /mob/living/basic/shade))
		return ..()
	return FALSE
