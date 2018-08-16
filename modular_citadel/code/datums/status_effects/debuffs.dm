/datum/status_effect/incapacitating/knockdown/on_creation(mob/living/new_owner, set_duration, updating_canmove, override_duration, override_stam)
	if(iscarbon(new_owner) && (isnum(set_duration) || isnum(override_duration)))
		new_owner.resting = TRUE
		new_owner.adjustStaminaLoss(isnull(override_stam)? set_duration*0.25 : override_stam)
		if(isnull(override_duration) && (set_duration > 80))
			set_duration = set_duration*0.01
			return ..()
		else if(!isnull(override_duration))
			set_duration = override_duration
			return ..()
		else if(updating_canmove)
			new_owner.update_canmove()
		qdel(src)
	else
		. = ..()
