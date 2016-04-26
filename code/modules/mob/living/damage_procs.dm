
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/used_weapon = null)
	if(!damage || (blocked >= 2))	return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage/(blocked+1))
		if(BURN)
			if(M_RESIST_HEAT in mutations)	damage = 0
			adjustFireLoss(damage/(blocked+1))
		if(TOX)
			adjustToxLoss(damage/(blocked+1))
		if(OXY)
			adjustOxyLoss(damage/(blocked+1))
		if(CLONE)
			adjustCloneLoss(damage/(blocked+1))
		if(HALLOSS)
			adjustHalLoss(damage/(blocked+1))
	updatehealth()
	return 1


/mob/living/proc/apply_damages(var/brute = 0, var/burn = 0, var/tox = 0, var/oxy = 0, var/clone = 0, var/halloss = 0, var/def_zone = null, var/blocked = 0)
	if(blocked >= 2)	return 0
	if(brute)	apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)	apply_damage(burn, BURN, def_zone, blocked)
	if(tox)		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)	apply_damage(clone, CLONE, def_zone, blocked)
	if(halloss) apply_damage(halloss, HALLOSS, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	if(!effect || (blocked >= 2))	return 0
	var/altered = 0
	switch(effecttype)
		if(STUN)
			altered = effect/(blocked+1)
			Stun(altered)
		if(WEAKEN)
			altered = effect/(blocked+1)
			Weaken(altered)
		if(PARALYZE)
			altered = effect/(blocked+1)
			Paralyse(altered)
		if(AGONY)
			altered = effect
			halloss += altered // Useful for objects that cause "subdual" damage. PAIN!
		if(IRRADIATE)
			altered = max((((effect - (effect*(getarmor(null, "rad")/100))))/(blocked+1)),0)//Rads auto check armor
			radiation += altered
		if(STUTTER)
			if(status_flags & CANSTUN) // stun is usually associated with stutter
				altered = max(stuttering,(effect/(blocked+1)))
				stuttering = altered
		if(EYE_BLUR)
			altered = max(eye_blurry,(effect/(blocked+1)))
			eye_blurry = altered
		if(DROWSY)
			altered = max(drowsyness,(effect/(blocked+1)))
			drowsyness = altered
	updatehealth()
	return altered


/mob/living/proc/apply_effects(var/stun = 0, var/weaken = 0, var/paralyze = 0, var/irradiate = 0, var/stutter = 0, var/eyeblur = 0, var/drowsy = 0, var/agony = 0, var/blocked = 0)
	if(blocked >= 2)	return 0
	if(stun)		apply_effect(stun, STUN, blocked)
	if(weaken)		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)	apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)	apply_effect(irradiate, IRRADIATE, blocked)
	if(stutter)		apply_effect(stutter, STUTTER, blocked)
	if(eyeblur)		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)		apply_effect(drowsy, DROWSY, blocked)
	if(agony)		apply_effect(agony, AGONY, blocked)
	return 1

/mob/living/ashify()
	return //let's not go ashy, shall we?
