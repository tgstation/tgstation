/proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/structure/table/optable, T))
		return 1
	else if(locate(/obj/machinery/stasis, T))
		return 0.9
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5


/proc/get_location_accessible(mob/M, location)
	var/covered_locations = 0	//based on body_parts_covered
	var/face_covered = 0	//based on flags_inv
	var/eyesmouth_covered = 0	//based on flags_cover
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask, C.head))
			covered_locations |= I.body_parts_covered
			face_covered |= I.flags_inv
			eyesmouth_covered |= I.flags_cover
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.ears))
				covered_locations |= I.body_parts_covered
				face_covered |= I.flags_inv
				eyesmouth_covered |= I.flags_cover

	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return 0
		if(BODY_ZONE_PRECISE_EYES)
			if(covered_locations & HEAD || face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES)
				return 0
		if(BODY_ZONE_PRECISE_MOUTH)
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH || eyesmouth_covered & HEADCOVERSMOUTH)
				return 0
		if(BODY_ZONE_CHEST)
			if(covered_locations & CHEST)
				return 0
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & GROIN)
				return 0
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return 0
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return 0
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return 0
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return 0
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return 0
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return 0
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return 0
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return 0

	return 1
