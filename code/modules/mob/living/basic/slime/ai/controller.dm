/datum/ai_controller/basic_controller/slime
	blackboard = list(
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_SLIME_RABID = FALSE,
		BB_SLIME_HUNGER_DISABLED = FALSE,
		BB_CURRENT_HUNTING_TARGET = null, // people whose energy we want to drain
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/change_slime_face,
		/datum/ai_planning_subtree/use_mob_ability/evolve,
		/datum/ai_planning_subtree/use_mob_ability/reproduce,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_and_hunt_target/find_slime_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/slime,
		/datum/ai_planning_subtree/random_speech/slime,
	)
	can_idle = FALSE

/datum/ai_controller/basic_controller/slime/CancelActions()
	..()
	if(QDELETED(pawn))
		return

	var/mob/living/basic/slime/slime_pawn = pawn
	slime_pawn.stop_feeding()
