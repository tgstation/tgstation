/* DISORIENTED */
/**
 * Applies the "disoriented" status effect to the mob, among other potential statuses.
 * Args:
 * * amount : duration for src to be disoriented
 * * stamina_amount : stamina damage to deal before LERP
 * * ignore_canstun : ignore stun immunities, if using a secondary form of status
 * * knockdown : duration to knock src down
 * * stun : duration to stun src
 * * paralyze : duration to paralyze src
 * * overstam : If TRUE, stamina_amount will be able to deal stamina damage over the waekened threshold, allowing it to also stamina stun.
 * * stack_status : Should the given status value(s) stack ontop of existing status values?
 */
/mob/living/proc/Disorient(amount, stamina_amount, ignore_canstun, knockdown, stun, paralyze, overstam, stack_status = TRUE)
	var/protection_amt = 0
	///placeholder
	var/disorient_multiplier = 1 - (protection_amt/100)
	var/stamina_multiplier = LERP(disorient_multiplier, 1, 0.25)

	var/stam2deal = stamina_amount * stamina_multiplier

	//You can never be stam-stunned w/o overstam
	if(overstam)
		stamina.adjust(-stam2deal)
	else
		var/threshold = (stamina.maximum * STAMINA_STUN_THRESHOLD_MODIFIER)
		stam2deal = stamina.current - stam2deal < threshold ? (stam2deal - threshold) : (stam2deal)
		if(stam2deal)
			stamina.adjust(-stam2deal)

	if(HAS_TRAIT(src, TRAIT_EXHAUSTED))
		if(knockdown)
			if(stack_status)
				AdjustKnockdown(knockdown, ignore_canstun, TRUE)
			else
				Knockdown(knockdown, ignore_canstun, TRUE)

		if(paralyze)
			if(stack_status)
				AdjustParalyzed(paralyze, ignore_canstun, TRUE)
			else
				Paralyze(paralyze, ignore_canstun, TRUE)

		if(stun)
			if(stack_status)
				AdjustStun(stun, ignore_canstun, TRUE)
			else
				Stun(stun, ignore_canstun, TRUE)

	if(amount > 0)
		adjust_timed_status_effect(amount, /datum/status_effect/incapacitating/disoriented, 15 SECONDS)
		var/datum/status_effect/incapacitating/disoriented/existing = has_status_effect(/datum/status_effect/incapacitating/disoriented)
		existing.knockdown += knockdown
		existing.paralyze += paralyze
		existing.stun += stun


	return


/mob/living/proc/IsDisoriented() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/disoriented)

/mob/living/proc/AmountDisoriented() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/disoriented/P = IsDisoriented()
	if(P)
		return P.duration - world.time
	return 0
