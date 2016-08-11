
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = 0)
	blocked = (100-blocked)/100
	if(!damage || (blocked <= 0))
		return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage * blocked)
		if(BURN)
			adjustFireLoss(damage * blocked)
		if(TOX)
			adjustToxLoss(damage * blocked)
		if(OXY)
			adjustOxyLoss(damage * blocked)
		if(CLONE)
			adjustCloneLoss(damage * blocked)
		if(STAMINA)
			adjustStaminaLoss(damage * blocked)
	updatehealth()
	return 1


/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = 0, stamina = 0)
	if(blocked >= 100)
		return 0
	if(brute)
		apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)
		apply_damage(burn, BURN, def_zone, blocked)
	if(tox)
		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)
		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)
		apply_damage(clone, CLONE, def_zone, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(effect = 0,effecttype = STUN, blocked = 0)
	blocked = (100-blocked)/100
	if(!effect || (blocked <= 0))
		return 0
	switch(effecttype)
		if(STUN)
			Stun(effect * blocked)
		if(WEAKEN)
			Weaken(effect * blocked)
		if(PARALYZE)
			Paralyse(effect * blocked)
		if(IRRADIATE)
			radiation += max(effect * blocked, 0)
		if(SLUR)
			slurring = max(slurring,(effect * blocked))
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				stuttering = max(stuttering,(effect * blocked))
		if(EYE_BLUR)
			blur_eyes(effect * blocked)
		if(DROWSY)
			drowsyness = max(drowsyness,(effect * blocked))
		if(JITTER)
			if(status_flags & CANSTUN)
				jitteriness = max(jitteriness,(effect * blocked))
	return 1


/mob/living/proc/apply_effects(stun = 0, weaken = 0, paralyze = 0, irradiate = 0, slur = 0, stutter = 0, eyeblur = 0, drowsy = 0, blocked = 0, stamina = 0, jitter = 0)
	if(blocked >= 100)
		return 0
	if(stun)
		apply_effect(stun, STUN, blocked)
	if(weaken)
		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)
		apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)
		apply_effect(irradiate, IRRADIATE, blocked)
	if(slur)
		apply_effect(slur, SLUR, blocked)
	if(stutter)
		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)
		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)
		apply_effect(drowsy, DROWSY, blocked)
	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)
	if(jitter)
		apply_effect(jitter, JITTER, blocked)
	return 1