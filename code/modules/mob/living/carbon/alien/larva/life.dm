

/mob/living/carbon/alien/larva/Life(seconds_per_tick = SSMOBS_DT)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		return
	if(!..() || HAS_TRAIT(src, TRAIT_STASIS) || (amount_grown >= XENOMORPH_MAX_GROWTH))
		return // We're dead, in stasis, or already grown.
	// GROW!
	amount_grown = min(amount_grown + (0.5 * seconds_per_tick), XENOMORPH_MAX_GROWTH)
	update_icons()

/mob/living/carbon/alien/larva/on_knockedout_trait_loss(datum/source)
	. = ..()
	set_resting(FALSE)

/mob/living/carbon/alien/larva/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		if(health <= -maxHealth || !get_organ_by_type(/obj/item/organ/brain))
			death()
			return
		set_stat(STABLE)
	update_damage_hud()
	update_health_hud()
