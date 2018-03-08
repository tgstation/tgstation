/datum/species/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	if(H.checkbuttinsert(I, user))
		return FALSE

	return ..()