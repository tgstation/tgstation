/mob/living/proc/check_contact_sterility(body_part)
	return 0

/mob/living/carbon/human/check_contact_sterility(body_part)
	var/block = FALSE
	var/list/clothing_to_check = list(
		wear_mask,
		w_uniform,
		head,
		wear_suit,
		back,
		gloves,
		handcuffed,
		legcuffed,
		belt,
		shoes,
		wear_mask,
		glasses,
		ears,
		wear_id)

	for (var/thing in clothing_to_check)
		var/obj/item/cloth = thing
		if(istype(cloth) && (cloth.body_parts_covered & body_part) && prob(cloth.get_armor_rating(BIO)))
			block = TRUE
	return block


/mob/living/proc/check_bodypart_bleeding(zone)
	return FALSE

/mob/living/carbon/check_bodypart_bleeding(zone)
	var/obj/item/bodypart/bodypart = get_bodypart(zone)
	if(bodypart.get_modified_bleed_rate())
		return TRUE
	return FALSE
