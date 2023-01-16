/// Pet owners can't see their pet's ability cooldowns so we keep attempting to use an ability until we succeed
/datum/ai_behavior/pet_use_ability
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/pet_use_ability/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()
	if (QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/pet_use_ability/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/mob_cooldown/ability = controller.blackboard[ability_key]
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()
	if (!ability || QDELETED(target))
		finish_action(controller, FALSE, ability_key, target_key)
		return
	var/mob/pawn = controller.pawn
	if (ability.InterceptClickOn(pawn, null, target))
		finish_action(controller, TRUE, ability_key, target_key)

/datum/ai_behavior/pet_use_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.blackboard[target_key] = null
