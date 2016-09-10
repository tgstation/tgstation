
/mob/living/simple_animal/proc/adjustHealth(amount)
	if(status_flags & GODMODE)
		return 0
	bruteloss = Clamp(bruteloss + amount, 0, maxHealth)
	updatehealth()
	return amount

/mob/living/simple_animal/adjustBruteLoss(amount)
	if(damage_coeff[BRUTE])
		. = adjustHealth(amount * damage_coeff[BRUTE] * config.damage_multiplier)

/mob/living/simple_animal/adjustFireLoss(amount)
	if(damage_coeff[BURN])
		. = adjustHealth(amount * damage_coeff[BURN] * config.damage_multiplier)

/mob/living/simple_animal/adjustOxyLoss(amount)
	if(damage_coeff[OXY])
		. = adjustHealth(amount * damage_coeff[OXY] * config.damage_multiplier)

/mob/living/simple_animal/adjustToxLoss(amount)
	if(damage_coeff[TOX])
		. = adjustHealth(amount * damage_coeff[TOX] * config.damage_multiplier)

/mob/living/simple_animal/adjustCloneLoss(amount)
	if(damage_coeff[CLONE])
		. = adjustHealth(amount * damage_coeff[CLONE] * config.damage_multiplier)

/mob/living/simple_animal/adjustStaminaLoss(amount)
	return
