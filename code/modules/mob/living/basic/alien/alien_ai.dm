/datum/ai_controller/basic_controller/alien
	behavior_tree_json = "alien.bt.json"
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 3,
	)

	movement_delay = 0.8 SECONDS

/datum/ai_controller/basic_controller/alien/sentinel
	behavior_tree_json = "sentinel.bt.json"


/datum/ai_controller/basic_controller/alien/drone
	behavior_tree_json = "drone.bt.json"

/datum/ai_controller/basic_controller/alien/queen
	behavior_tree_json = "queen.bt.json"
/**
 * Alien projectile
 * Try to avoid friendly fire, and has a 3 second delay.
 */
/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/alien

/datum/ai_behavior/basic_ranged_attack/alien
	time_between_perform = 3 SECONDS
	max_range = 3
	avoid_friendly_fire = TRUE

/datum/bt_node/subtree/basic_alien
	behavior_tree_json = "basic_alien.bt.json"


/datum/bt_node/subtree/ranged_alien_combat
	behavior_tree_json = "ranged_alien_combat.bt.json"


/datum/bt_node/subtree/melee_alien_combat
	behavior_tree_json = "melee_alien_combat.bt.json"

/datum/bt_node/subtree/plant_alien_weeds
	behavior_tree_json = "plant_alien_weeds.bt.json"

/datum/bt_node/subtree/lay_alien_egg
	behavior_tree_json = "lay_alien_egg.bt.json"


/// Plants alien weeds on the pawn's current turf. Fails if the pawn can't plant or weeds couldn't be placed.
/datum/bt_node/ai_behavior/plant_alien_weeds

/datum/bt_node/ai_behavior/plant_alien_weeds/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/alien/alien_pawn = controller.pawn
	if(!alien_pawn.can_plant_weeds || !alien_pawn.place_weeds())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/// Lays an alien egg on the pawn's current turf. Fails if the pawn can't lay eggs or an egg couldn't be placed.
/datum/bt_node/ai_behavior/lay_alien_egg

/datum/bt_node/ai_behavior/lay_alien_egg/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/basic/alien/alien_pawn = controller.pawn
	if(!alien_pawn.can_lay_eggs || !alien_pawn.lay_alien_egg())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
