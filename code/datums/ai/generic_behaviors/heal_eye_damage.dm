/// Heals the eye damage of the keyed target. Movement to the target is handled externally.
/datum/bt_node/ai_behavior/heal_eye_damage
	/// Blackboard key holding the target whose eyes we heal.
	var/target_key

/datum/bt_node/ai_behavior/heal_eye_damage/setup(datum/ai_controller/controller)
	var/mob/living/carbon/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/bt_node/ai_behavior/heal_eye_damage/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/carbon/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/mob/living/basic/eyeball/eye = controller.pawn
	var/obj/item/organ/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	eye.heal_eye_damage(target, eyes)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/heal_eye_damage/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)
