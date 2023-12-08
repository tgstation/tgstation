/mob/living/proc/check_contact_sterility(body_part)
	return 0

/mob/living/carbon/human/check_contact_sterility(body_part)
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

	var/list/checks = list(body_part)
	if(body_part == BODY_ZONE_EVERYTHING)
		checks = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
	if(body_part == BODY_ZONE_LEGS)
		checks = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	if(body_part == BODY_ZONE_ARMS)
		checks = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	
	for(var/item in checks)
		for (var/thing in clothing_to_check)
			var/obj/item/cloth = thing
			if(isnull(cloth))
				continue
			var/list/coverage = cover_flags2body_zones(cloth.body_parts_covered)
			if((item in coverage) && prob(cloth.get_armor_rating(BIO)))
				return TRUE
	return FALSE


/mob/living/proc/check_bodypart_bleeding(zone)
	return FALSE

/mob/living/carbon/human/check_bodypart_bleeding(zone)
	var/bleeding = FALSE
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
	var/list/checks = list(zone)
	if(zone == BODY_ZONE_EVERYTHING)
		checks = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_R_ARM, BODY_ZONE_HEAD)
	if(zone == BODY_ZONE_LEGS)
		checks = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	if(zone == BODY_ZONE_ARMS)
		checks = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

	for(var/item in checks)
		var/obj/item/bodypart/bodypart = get_bodypart(item)
		if(!bodypart)
			return FALSE
		for (var/thing in clothing_to_check)
			var/obj/item/cloth = thing
			if(!cloth)
				if(bodypart.get_modified_bleed_rate())	
					return TRUE
			else if(istype(cloth) && (cloth.body_parts_covered & body_zone2cover_flags(item)) && !prob(cloth.get_armor_rating(BIO)))
				if(bodypart.get_modified_bleed_rate())	
					return TRUE
	return bleeding

/mob/living/proc/check_airborne_sterility()
	return 0

/mob/living/carbon/human/check_airborne_sterility()
	var/block = FALSE
	if (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && prob(wear_mask.get_armor_rating(BIO)))
		block = TRUE
	if (head && (head.flags_cover & HEADCOVERSMOUTH) && prob(head.get_armor_rating(BIO)))
		block = TRUE
	return block
