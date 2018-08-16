/mob/living/Knockdown(amount, updating = TRUE, ignore_canknockdown = FALSE, override_hardstun, override_stamdmg) //Can't go below remaining duration
	if(((status_flags & CANKNOCKDOWN) && !has_trait(TRAIT_STUNIMMUNE)) || ignore_canknockdown)
		if(absorb_stun(isnull(override_hardstun)? amount : override_hardstun, ignore_canknockdown))
			return
		var/datum/status_effect/incapacitating/knockdown/K = IsKnockdown()
		if(K)
			K.duration = max(world.time + (isnull(override_hardstun)? amount : override_hardstun), K.duration)
		else if((amount || override_hardstun) > 0)
			K = apply_status_effect(STATUS_EFFECT_KNOCKDOWN, amount, updating, override_hardstun, override_stamdmg)
		return K
