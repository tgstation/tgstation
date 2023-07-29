/datum/status_effect/incapacitating/disoriented
	id = "disoriented"
	tick_interval = 1 SECONDS
	var/last_twitch = 0

/datum/status_effect/incapacitating/disoriented/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/disoriented/on_remove()
	REMOVE_TRAIT(owner, TRAIT_DISORIENTED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/disoriented/tick()
	if(last_twitch < world.time + 7 && (!HAS_TRAIT(owner, TRAIT_IMMOBILIZED)))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/atom/movable, twitch))
		playsound(owner, 'goon/sounds/electric_shock_short.ogg', 35, TRUE, 0.5, 1.5)
		last_twitch = world.time

///An animation for the object shaking wildly.
/atom/movable/proc/twitch()
	var/degrees = rand(-45,45)
	transform = transform.Turn(degrees)
	var/old_x = pixel_x
	var/old_y = pixel_y
	pixel_x += rand(-3,3)
	pixel_y += rand(-1,1)

	sleep(0.2 SECONDS)

	transform = transform.Turn(-degrees)
	pixel_x = old_x
	pixel_y = old_y



/// Normally this should go in status_procs, but it'll make gobloads of merge conflicts and I do not feel like bothering
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

	var/curr_confusion = get_timed_status_effect_duration(/datum/status_effect/confusion)
	set_timed_status_effect(min(curr_confusion + amount, 15 SECONDS), /datum/status_effect/confusion)

	if(HAS_TRAIT(src, TRAIT_EXHAUSTED))
		if(knockdown)
			if(stack_status)
				AdjustKnockdown(knockdown, ignore_canstun)
			else
				Knockdown(knockdown, ignore_canstun)

		if(paralyze)
			if(stack_status)
				AdjustParalyzed(paralyze, ignore_canstun)
			else
				Paralyze(paralyze, ignore_canstun)

		if(stun)
			if(stack_status)
				AdjustStun(stun, ignore_canstun)
			else
				Stun(stun, ignore_canstun)

	if(amount > 0)
		adjust_timed_status_effect(amount, /datum/status_effect/incapacitating/disoriented, 15 SECONDS)

	return


/mob/living/proc/IsDisoriented() //If we're paralyzed
	return has_status_effect(/datum/status_effect/incapacitating/disoriented)

/mob/living/proc/AmountDisoriented() //How many deciseconds remain in our Paralyzed status effect
	var/datum/status_effect/incapacitating/disoriented/P = IsDisoriented()
	if(P)
		return P.duration - world.time
	return 0
