
/**
 * Applies damage to this mob
 *
 * Sends [COMSIG_MOB_APPLY_DAMAGE]
 *
 * Arguuments:
 * * damage - amount of damage
 * * damagetype - one of [BRUTE], [BURN], [TOX], [OXY], [CLONE], [STAMINA]
 * * def_zone - zone that is being hit if any
 * * blocked - armor value applied
 * * forced - bypass hit percentage
 * * spread_damage - used in overrides
 *
 * Returns TRUE if damage applied
 */
/mob/living/proc/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, spread_damage = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE, attack_direction = null)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone)
	var/hit_percent = (100-blocked)/100
	if(!damage || (!forced && hit_percent <= 0))
		return FALSE
	var/damage_amount = forced ? damage : damage * hit_percent
	switch(damagetype)
		if(BRUTE)
			adjustBruteLoss(damage_amount, forced = forced)
		if(BURN)
			adjustFireLoss(damage_amount, forced = forced)
		if(TOX)
			adjustToxLoss(damage_amount, forced = forced)
		if(OXY)
			adjustOxyLoss(damage_amount, forced = forced)
		if(CLONE)
			adjustCloneLoss(damage_amount, forced = forced)
		if(STAMINA)
			adjustStaminaLoss(damage_amount, forced = forced)
	return TRUE

///like [apply_damage][/mob/living/proc/apply_damage] except it always uses the damage procs
/mob/living/proc/apply_damage_type(damage = 0, damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return adjustBruteLoss(damage)
		if(BURN)
			return adjustFireLoss(damage)
		if(TOX)
			return adjustToxLoss(damage)
		if(OXY)
			return adjustOxyLoss(damage)
		if(CLONE)
			return adjustCloneLoss(damage)
		if(STAMINA)
			return adjustStaminaLoss(damage)

/// return the damage amount for the type given
/mob/living/proc/get_damage_amount(damagetype = BRUTE)
	switch(damagetype)
		if(BRUTE)
			return getBruteLoss()
		if(BURN)
			return getFireLoss()
		if(TOX)
			return getToxLoss()
		if(OXY)
			return getOxyLoss()
		if(CLONE)
			return getCloneLoss()
		if(STAMINA)
			return getStaminaLoss()

/// applies multiple damages at once via [/mob/living/proc/apply_damage]
/mob/living/proc/apply_damages(brute = 0, burn = 0, tox = 0, oxy = 0, clone = 0, def_zone = null, blocked = FALSE, stamina = 0, brain = 0)
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
	if(brain)
		apply_damage(brain, BRAIN, def_zone, blocked)
	return 1


/// applies various common status effects or common hardcoded mob effects
/mob/living/proc/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = 0)
	var/hit_percent = (100-blocked)/100
	if(!effect || (hit_percent <= 0))
		return FALSE
	switch(effecttype)
		if(EFFECT_STUN)
			Stun(effect * hit_percent)
		if(EFFECT_KNOCKDOWN)
			Knockdown(effect * hit_percent)
		if(EFFECT_PARALYZE)
			Paralyze(effect * hit_percent)
		if(EFFECT_IMMOBILIZE)
			Immobilize(effect * hit_percent)
		if(EFFECT_UNCONSCIOUS)
			Unconscious(effect * hit_percent)

	return TRUE

/**
 * Applies multiple effects at once via [/mob/living/proc/apply_effect]
 *
 * Pretty much only used for projectiles applying effects on hit,
 * don't use this for anything else please just cause the effects directly
 */
/mob/living/proc/apply_effects(
		stun = 0,
		knockdown = 0,
		unconscious = 0,
		slur = 0 SECONDS, // Speech impediment, not technically an effect
		stutter = 0 SECONDS, // Ditto
		eyeblur = 0 SECONDS,
		drowsy = 0 SECONDS,
		blocked = 0, // This one's not an effect, don't be confused - it's block chance
		stamina = 0, // This one's a damage type, and not an effect
		jitter = 0 SECONDS,
		paralyze = 0,
		immobilize = 0,
	)

	if(blocked >= 100)
		return FALSE

	if(stun)
		apply_effect(stun, EFFECT_STUN, blocked)
	if(knockdown)
		apply_effect(knockdown, EFFECT_KNOCKDOWN, blocked)
	if(unconscious)
		apply_effect(unconscious, EFFECT_UNCONSCIOUS, blocked)
	if(paralyze)
		apply_effect(paralyze, EFFECT_PARALYZE, blocked)
	if(immobilize)
		apply_effect(immobilize, EFFECT_IMMOBILIZE, blocked)

	if(stamina)
		apply_damage(stamina, STAMINA, null, blocked)

	if(drowsy)
		adjust_drowsiness(drowsy)
	if(eyeblur)
		adjust_eye_blur(eyeblur)
	if(jitter && (status_flags & CANSTUN) && !HAS_TRAIT(src, TRAIT_STUNIMMUNE))
		adjust_jitter(jitter)
	if(slur)
		adjust_slurring(slur)
	if(stutter)
		adjust_stutter(stutter)

	return TRUE


/mob/living/proc/getBruteLoss()
	return bruteloss

/mob/living/proc/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	bruteloss = clamp((bruteloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return
	. = bruteloss
	bruteloss = amount
	if(updating_health)
		updatehealth()

/mob/living/proc/getOxyLoss()
	return oxyloss

/mob/living/proc/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype = MOB_ORGANIC)
	if(!forced && (status_flags & GODMODE))
		return
	if(!(mob_biotypes & required_biotype))
		return
	. = oxyloss
	oxyloss = clamp((oxyloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	if(updating_health)
		updatehealth()


/mob/living/proc/setOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!forced && (status_flags & GODMODE))
		return
	if(required_biotype && !(mob_biotypes & required_biotype))
		return
	. = oxyloss
	oxyloss = amount
	if(updating_health)
		updatehealth()


/mob/living/proc/getToxLoss()
	return toxloss

/mob/living/proc/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(required_biotype && !(mob_biotypes & required_biotype))
		return
	toxloss = clamp((toxloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(required_biotype && !(mob_biotypes & required_biotype))
		return
	toxloss = amount
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/getFireLoss()
	return fireloss

/mob/living/proc/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	fireloss = clamp((fireloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!forced && (status_flags & GODMODE))
		return
	. = fireloss
	fireloss = amount
	if(updating_health)
		updatehealth()

/mob/living/proc/getCloneLoss()
	return cloneloss

/mob/living/proc/adjustCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!forced && ( (status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)) )
		return FALSE
	cloneloss = clamp((cloneloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, maxHealth * 2)
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/setCloneLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!forced && ( (status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)) )
		return FALSE
	cloneloss = amount
	if(updating_health)
		updatehealth()
	return amount

/mob/living/proc/adjustOrganLoss(slot, amount, maximum, required_organtype)
	return

/mob/living/proc/setOrganLoss(slot, amount, maximum, required_organtype)
	return

/mob/living/proc/getOrganLoss(slot)
	return

/mob/living/proc/getStaminaLoss()
	return staminaloss

/mob/living/proc/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!forced && (status_flags & GODMODE))
		return FALSE
	if(required_biotype && !(mob_biotypes & required_biotype))
		return
	staminaloss = clamp((staminaloss + (amount * CONFIG_GET(number/damage_multiplier))), 0, max_stamina)
	if(updating_stamina)
		update_stamina()
	return

/mob/living/proc/setStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!forced && ( (status_flags & GODMODE) || HAS_TRAIT(src, TRAIT_NOCLONELOSS)) )
		return FALSE
	staminaloss = amount
	if(updating_stamina)
		update_stamina()

/**
 * heal ONE external organ, organ gets randomly selected from damaged ones.
 *
 * needs to return amount healed in order to calculate things like tend wounds xp gain
 */
/mob/living/proc/heal_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_bodytype)
	. = (adjustBruteLoss(-brute, FALSE) + adjustFireLoss(-burn, FALSE)) //zero as argument for no instant health update
	if(updating_health)
		updatehealth()

/// damage ONE external organ, organ gets randomly selected from damaged ones.
/mob/living/proc/take_bodypart_damage(brute = 0, burn = 0, updating_health = TRUE, required_bodytype, check_armor = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = NONE)
	adjustBruteLoss(brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(burn, FALSE)
	if(updating_health)
		updatehealth()

/// heal MANY bodyparts, in random order
/mob/living/proc/heal_overall_damage(brute = 0, burn = 0, stamina = 0, required_bodytype, updating_health = TRUE)
	adjustBruteLoss(-brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(-burn, FALSE)
	adjustStaminaLoss(-stamina, FALSE)
	if(updating_health)
		updatehealth()

/// damage MANY bodyparts, in random order
/mob/living/proc/take_overall_damage(brute = 0, burn = 0, stamina = 0, updating_health = TRUE, required_bodytype)
	adjustBruteLoss(brute, FALSE) //zero as argument for no instant health update
	adjustFireLoss(burn, FALSE)
	adjustStaminaLoss(stamina, FALSE)
	if(updating_health)
		updatehealth()

///heal up to amount damage, in a given order
/mob/living/proc/heal_ordered_damage(amount, list/damage_types)
	. = amount //we'll return the amount of damage healed
	for(var/i in damage_types)
		var/amount_to_heal = min(amount, get_damage_amount(i)) //heal only up to the amount of damage we have
		if(amount_to_heal)
			apply_damage_type(-amount_to_heal, i)
			amount -= amount_to_heal //remove what we healed from our current amount
		if(!amount)
			break
	. -= amount //if there's leftover healing, remove it from what we return
