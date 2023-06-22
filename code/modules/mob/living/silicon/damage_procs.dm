
/mob/living/silicon/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE, attack_direction = null, attacking_item)
	var/hit_percent = (100-blocked)/100
	if((!damage || (!forced && hit_percent <= 0)))
		return 0
	var/damage_amount = forced ? damage : damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			adjustFireLoss(damage_amount, forced = forced)
	return 1


/mob/living/silicon/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = FALSE)
	return FALSE //The only effect that can hit them atm is flashes and they still directly edit so this works for now. (This was written in at least 2016. Help)

/mob/living/silicon/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype) //immune to tox damage
	return FALSE

/mob/living/silicon/setToxLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE) //immune to clone damage
	return FALSE

/mob/living/silicon/setCloneLoss(amount, updating_health = TRUE, forced = FALSE)
	return FALSE

/mob/living/silicon/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype) //immune to stamina damage.
	return FALSE

/mob/living/silicon/setStaminaLoss(amount, updating_health = TRUE)
	return FALSE

/mob/living/silicon/adjustOrganLoss(slot, amount, maximum = 500, required_organtype) //immune to organ damage (no organs, duh)
	return FALSE

/mob/living/silicon/setOrganLoss(slot, amount)
	return FALSE

/mob/living/silicon/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type) //immune to oxygen damage
	if(isAI(src)) //ais are snowflakes and use oxyloss for being in AI cards and having no battery
		return ..()

	return FALSE

/mob/living/silicon/setOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(isAI(src)) //ditto
		return ..()

	return FALSE
