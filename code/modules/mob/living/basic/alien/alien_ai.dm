/datum/ai_controller/basic_controller/alien
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

	movement_delay = 0.8 SECONDS

/datum/ai_controller/basic_controller/alien/sentinel
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien,
	)

/datum/ai_controller/basic_controller/alien/drone
	idle_behavior = /datum/idle_behavior/idle_random_walk/plant_weeds

/datum/ai_controller/basic_controller/alien/queen
	idle_behavior = /datum/idle_behavior/idle_random_walk/plant_weeds/queen

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien,
	)

/**
 * Alien projectile
 * Try to avoid friendly fire, and has a 3 second delay.
 */
/datum/ai_planning_subtree/basic_ranged_attack_subtree/alien
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/alien

/datum/ai_behavior/basic_ranged_attack/alien
	action_cooldown = 3 SECONDS
	required_distance = 3
	avoid_friendly_fire = TRUE

/datum/idle_behavior/idle_random_walk/plant_weeds
	var/plant_cooldown = 30
	var/plants_off = 0

/datum/idle_behavior/idle_random_walk/plant_weeds/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(!.)
		return .
	plant_cooldown--
	var/mob/living/basic/alien/alien_pawn = controller.pawn
	if(alien_pawn.can_plant_weeds && !plants_off && plant_cooldown <= 0)
		plant_cooldown = initial(plant_cooldown)
		alien_pawn.place_weeds()

/datum/idle_behavior/idle_random_walk/plant_weeds/queen
	var/eggs_off = 0
	var/egg_cooldown = 30

/datum/idle_behavior/idle_random_walk/plant_weeds/queen/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	if(!.)
		return .
	egg_cooldown--
	var/mob/living/basic/alien/alien_pawn = controller.pawn
	if(alien_pawn.can_lay_eggs && !eggs_off && egg_cooldown <= 0)
		egg_cooldown = initial(egg_cooldown)
		alien_pawn.lay_alien_egg()
