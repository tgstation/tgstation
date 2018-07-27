/mob/living/carbon/get_footstep_modifiers()
	if(!..() || !get_bodypart(BODY_ZONE_L_LEG) || !get_bodypart(BODY_ZONE_R_LEG))
		return null
	return list(1, 2)