/proc/get_location_modifier(mob/located_mob)
	var/turf/mob_turf = get_turf(located_mob)
	if(locate(/obj/structure/table/optable, mob_turf))
		return 1
	else if(locate(/obj/machinery/stasis, mob_turf))
		return 0.9
	else if(locate(/obj/structure/table, mob_turf))
		return 0.8
	else if(locate(/obj/structure/bed, mob_turf))
		return 0.7
	else
		return 0.5


/proc/get_location_accessible(mob/located_mob, location)
	var/covered_locations = 0 //based on body_parts_covered
	var/face_covered = 0 //based on flags_inv
	var/eyesmouth_covered = 0 //based on flags_cover
	if(iscarbon(located_mob))
		var/mob/living/carbon/clothed_carbon = located_mob
		for(var/obj/item/clothing/clothes in list(clothed_carbon.back, clothed_carbon.wear_mask, clothed_carbon.head))
			covered_locations |= clothes.body_parts_covered
			face_covered |= clothes.flags_inv
			eyesmouth_covered |= clothes.flags_cover
		if(ishuman(clothed_carbon))
			var/mob/living/carbon/human/clothed_human = clothed_carbon
			for(var/obj/item/clothes in list(clothed_human.wear_suit, clothed_human.w_uniform, clothed_human.shoes, clothed_human.belt, clothed_human.gloves, clothed_human.glasses, clothed_human.ears))
				covered_locations |= clothes.body_parts_covered
				face_covered |= clothes.flags_inv
				eyesmouth_covered |= clothes.flags_cover

	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return FALSE
		if(BODY_ZONE_PRECISE_EYES)
			if(covered_locations & HEAD || face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES)
				return FALSE
		if(BODY_ZONE_PRECISE_MOUTH)
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH || eyesmouth_covered & HEADCOVERSMOUTH)
				return FALSE
		if(BODY_ZONE_CHEST)
			if(covered_locations & CHEST)
				return FALSE
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & GROIN)
				return FALSE
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return FALSE
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return FALSE
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return FALSE
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return FALSE

	return TRUE
