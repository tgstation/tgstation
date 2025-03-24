/obj/item/organ/brain/cybernetic/ai/is_sufficiently_augmented()
	var/mob/living/carbon/carb_owner = owner
	if(!istype(carb_owner))
		return
	return TRUE
