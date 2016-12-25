
/mob/living/silicon/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = 0)
	var/hit_percent = (100-blocked)/100
	if(!damage || (hit_percent <= 0))
		return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * hit_percent)
		if(BURN)
			adjustFireLoss(damage * hit_percent)
	return 1


/mob/living/silicon/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	return 0 //The only effect that can hit them atm is flashes and they still directly edit so this works for now

/mob/living/silicon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE) //immune to tox damage
	return FALSE

/mob/living/silicon/setToxLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE) //immune to clone damage
	return FALSE

/mob/living/silicon/setCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustStaminaLoss(amount, updating_stamina = 1)//immune to stamina damage.
	return

/mob/living/silicon/setStaminaLoss(amount, updating_stamina = 1)
	return

