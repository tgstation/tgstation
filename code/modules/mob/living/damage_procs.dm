
/*
	apply_damage(a,b,c)
	args
	a:damage - How much damage to take
	b:damage_type - What type of damage to take, brute, burn
	c:def_zone - Where to take the damage if its brute or burn
	Returns
	standard 0 if fail
*/
/mob/living/proc/apply_damage(var/damage = 0,var/damagetype = BRUTE, var/def_zone = null, var/blocked = 0, var/sharp = 0, var/used_weapon = null)
	if(!damage || (blocked >= 2))	return 0
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage/(blocked+1), used_weapon)
		if(BURN)
			if(mutations & COLD_RESISTANCE)	damage = 0
			adjustFireLoss(damage/(blocked+1), used_weapon)
		if(TOX)
			adjustToxLoss(damage/(blocked+1))
		if(OXY)
			adjustOxyLoss(damage/(blocked+1))
		if(CLONE)
			adjustCloneLoss(damage/(blocked+1))
	UpdateDamageIcon()
	updatehealth()
	return 1


/mob/living/proc/apply_damages(var/brute = 0, var/burn = 0, var/tox = 0, var/oxy = 0, var/clone = 0, var/def_zone = null, var/blocked = 0)
	if(blocked >= 2)	return 0
	if(brute)	apply_damage(brute, BRUTE, def_zone, blocked)
	if(burn)	apply_damage(burn, BURN, def_zone, blocked)
	if(tox)		apply_damage(tox, TOX, def_zone, blocked)
	if(oxy)		apply_damage(oxy, OXY, def_zone, blocked)
	if(clone)	apply_damage(clone, CLONE, def_zone, blocked)
	return 1



/mob/living/proc/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	if(!effect || (blocked))	return 0
	switch(effecttype)
		if(STUN)
			Stun((effect - (min(effect*getarmor(null, "laser"), effect*(0.75 + (blocked*0.05))))))
		if(WEAKEN)
			Weaken((effect - (min(effect*getarmor(null, "laser"), effect*(0.75 + (blocked*0.05))))))
		if(PARALYZE)
			Paralyse(effect/(blocked+1))
		if(IRRADIATE)
			radiation += max((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			if(canstun) // stun is usually associated with stutter
				stuttering = max(stuttering,(effect/(blocked+1)))
		if(SLUR)
			slurring = max(slurring, (effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	UpdateDamageIcon()
	updatehealth()
	return 1


/mob/living/proc/apply_effects(var/stun = 0, var/weaken = 0, var/paralyze = 0, var/irradiate = 0, var/stutter = 0, var/slur = 0, var/eyeblur = 0, var/drowsy = 0, var/blocked = 0)
	if(blocked >= 2)	return 0
	if(stun)		apply_effect(stun, STUN, blocked)
	if(weaken)		apply_effect(weaken, WEAKEN, blocked)
	if(paralyze)	apply_effect(paralyze, PARALYZE, blocked)
	if(irradiate)	apply_effect(irradiate, IRRADIATE, blocked)
	if(stutter)		apply_effect(stutter, STUTTER, blocked)
	if(slur)		apply_effect(slur, SLUR, blocked)
	if(eyeblur)		apply_effect(eyeblur, EYE_BLUR, blocked)
	if(drowsy)		apply_effect(drowsy, DROWSY, blocked)
	return 1


/mob/living/proc/react_to_attack(mob/M)
	return
