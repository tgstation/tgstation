
/mob/living/carbon/alien/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = 0)
	var/hit_percent = (100-blocked)/100
	if(!damage || (hit_percent <= 0))
		return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * hit_percent)
		if(BURN)
			adjustFireLoss(damage * 2 * hit_percent) // Xenos take double burn damage, MUY IMPORTANTE
		if(OXY)
			if(damage < 0) //we shouldn't be taking oxygen damage through this proc, but we'll let it heal.
				adjustOxyLoss(damage * hit_percent)
	return 1

//aliens are immune to stamina damage.
/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return
