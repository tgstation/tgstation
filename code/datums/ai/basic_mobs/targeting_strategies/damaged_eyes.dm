/// Accepts carbon mobs whose eyes are damaged at or beyond the controller's BB_EYE_DAMAGE_THRESHOLD.
/datum/targeting_strategy/damaged_eyes

/datum/targeting_strategy/damaged_eyes/is_valid_target(mob/living/living_mob, atom/target, vision_range, datum/ai_controller/controller = null)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target))
		return FALSE
	var/threshold = controller?.blackboard[BB_EYE_DAMAGE_THRESHOLD]
	if(!threshold)
		return FALSE
	var/mob/living/carbon/carbon_target = target
	var/obj/item/organ/eyes/eyes = carbon_target.get_organ_slot(ORGAN_SLOT_EYES)
	if(isnull(eyes) || eyes.damage < threshold)
		return FALSE
	return TRUE
