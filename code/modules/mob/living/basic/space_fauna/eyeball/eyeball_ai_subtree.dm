/datum/ai_controller/basic_controller/eyeball
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/eyeball,
		BB_EYE_DAMAGE_THRESHOLD = 10,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/eyeball/eyeball.bt.json"

/datum/targeting_strategy/basic/eyeball/is_valid_target(mob/living/owner, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!ishuman(target))
		return TRUE
	var/mob/living/carbon/human_target = target
	if(human_target.is_blind())
		return FALSE
	var/eye_damage_threshold = owner.ai_controller.blackboard[BB_EYE_DAMAGE_THRESHOLD]
	if(!eye_damage_threshold)
		return TRUE
	var/obj/item/organ/eyes/eyes = human_target.get_organ_slot(ORGAN_SLOT_EYES)
	if(eyes.damage > eye_damage_threshold) //we dont attack people with bad vision
		return FALSE

	return can_see(target, owner, 9) //if the target cant see us dont attack him
