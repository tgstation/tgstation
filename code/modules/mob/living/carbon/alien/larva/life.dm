

/mob/living/carbon/alien/larva/Life(delta_time = SSMOBS_DT, times_fired)
	if (notransform)
		return
	if(!..() || IS_IN_STASIS(src) || (amount_grown >= max_grown))
		return // We're dead, in stasis, or already grown.
	// GROW!
	amount_grown = min(amount_grown + (0.5 * delta_time), max_grown)
	update_icons()


/mob/living/carbon/alien/larva/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health<= -maxHealth || !getorgan(/obj/item/organ/brain))
			death()
			return
		if((HAS_TRAIT(src, TRAIT_KNOCKEDOUT)))
			set_stat(UNCONSCIOUS)
		else
			if(stat == UNCONSCIOUS)
				set_resting(FALSE)
			set_stat(CONSCIOUS)
	update_damage_hud()
	update_health_hud()
