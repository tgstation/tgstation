/mob/living/carbon/update_stat()
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return
	if(stat != DEAD)
		// if(health <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(src, TRAIT_NODEATH))
			// death()
			// return
		if(HAS_TRAIT_FROM(src, TRAIT_DISSECTED, AUTOPSY_TRAIT))
			REMOVE_TRAIT(src, TRAIT_DISSECTED, AUTOPSY_TRAIT)
		if(health <= hardcrit_threshold && !HAS_TRAIT(src, TRAIT_NOHARDCRIT))
			set_stat(HARD_CRIT)
		else if(HAS_TRAIT(src, TRAIT_KNOCKEDOUT))
			set_stat(UNCONSCIOUS)
		else if(health <= crit_threshold && !HAS_TRAIT(src, TRAIT_NOSOFTCRIT))
			set_stat(SOFT_CRIT)
		else
			set_stat(CONSCIOUS)
	update_damage_hud()
	update_health_hud()
	update_stamina_hud()
	med_hud_set_status()

/// Brain damage is how you die, the real question is how you get it
/obj/item/organ/brain/on_life(seconds_per_tick, times_fired)
	if(damage >= BRAIN_DAMAGE_DEATH)
		achieve_death()
	// If you don't have enough blood, your brain starts to go
	if((owner.blood_volume < BLOOD_VOLUME_SURVIVE) && !HAS_TRAIT(owner, TRAIT_NOBLOOD))
		var/rounded_brain_damage = round(0.01 * (BLOOD_VOLUME_NORMAL - owner.blood_volume), 0.25) * seconds_per_tick
		apply_organ_damage(rounded_brain_damage)
	// If you are past the point of passing out and not breathing, then you start to go as well
	if((owner.oxyloss >= OXYLOSS_PASSOUT_THRESHOLD) && owner.failed_last_breath && !HAS_TRAIT(owner, TRAIT_NOBREATH))
		var/rounded_suffocation_damage = round(0.01 * (150 / (100 / owner.oxyloss)), 0.25) * seconds_per_tick
		apply_organ_damage(rounded_suffocation_damage)
	// If you are super poisoned then thy end is now as well
	if(owner.toxloss >= 150)
		var/rounded_toxin_damage = round(0.01 * (150 / (100 / owner.toxloss)), 0.25) * seconds_per_tick
		apply_organ_damage(rounded_toxin_damage)

/// Synths need to do something different, as they don't breathe
/obj/item/organ/brain/cybernetic/on_life(seconds_per_tick, times_fired)
	if(damage >= BRAIN_DAMAGE_DEATH)
		achieve_death()
	if(owner.stat == SOFT_CRIT || owner.stat == HARD_CRIT)
		var/rounded_brain_damage = round((-0.02 * owner.health), 0.25) * seconds_per_tick
		apply_organ_damage(rounded_brain_damage)

/// Golems need to do something different, as they don't anything
/obj/item/organ/brain/golem/on_life(seconds_per_tick, times_fired)
	if(damage >= BRAIN_DAMAGE_DEATH)
		achieve_death()
	if(owner.stat == SOFT_CRIT || owner.stat == HARD_CRIT)
		var/rounded_brain_damage = round((-0.02 * owner.health), 0.25) * seconds_per_tick
		apply_organ_damage(rounded_brain_damage)

/// Kills the owner of the brain when called, logging the reason given to it
/obj/item/organ/brain/proc/achieve_death(reason)
	if(!reason)
		reason = "has been killed by brain damage."
	to_chat(owner, span_userdanger("The last spark of life in your brain fizzles out..."))
	owner.investigate_log(reason, INVESTIGATE_DEATHS)
	owner.death()
