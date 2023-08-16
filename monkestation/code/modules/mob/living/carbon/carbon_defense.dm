/mob/living/carbon/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(istype(E) && diseases.len)
		if(scan)
			E.scan(src, diseases, user)
		else
			E.extrapolate(src, diseases, user)
		return TRUE
	else
		return FALSE
