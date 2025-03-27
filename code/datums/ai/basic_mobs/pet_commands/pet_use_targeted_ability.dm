/// Pet owners can't see their pet's ability cooldowns so we keep attempting to use an ability until we succeed
/datum/ai_behavior/pet_use_ability
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/pet_use_ability/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/mob/living/target = controller.blackboard[target_key]
	if (QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/pet_use_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/mob_cooldown/ability = controller.blackboard[ability_key]
	var/mob/living/target = controller.blackboard[target_key]
	if (QDELETED(ability) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/pawn = controller.pawn
	if(QDELETED(pawn) || ability.InterceptClickOn(pawn, null, target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT

/datum/ai_behavior/pet_use_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/datum/ai_behavior/pet_use_ability/then_attack

/datum/ai_behavior/pet_use_ability/then_attack/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	if(succeeded)
		controller.queue_behavior(/datum/ai_behavior/basic_melee_attack, target_key, BB_PET_TARGETING_STRATEGY)

/datum/ai_behavior/pet_use_ability/then_attack/short_ranged
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 4

/datum/ai_behavior/pet_use_ability/then_attack/long_ranged
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 8
