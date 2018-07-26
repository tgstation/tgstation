/mob/living/carbon/get_footstep_factors()
	. = ..()
	if(!.)
		return
	if(!get_bodypart(BODY_ZONE_L_LEG) || !get_bodypart(BODY_ZONE_R_LEG))
		return null
	.[1] *= 2
	.[2] *= 2