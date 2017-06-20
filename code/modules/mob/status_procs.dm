
//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

#define STUN_TIME_MULTIPLIER 0.05 //temporary; multiplies input stun times by this, will be removed once stuns are status effects

/////////////////////////////////// STUN ////////////////////////////////////

/mob/proc/Stun(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stun = max(max(stun,amount * STUN_TIME_MULTIPLIER),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		if(updating)
			update_canmove()
		return TRUE

/mob/proc/SetStun(amount, updating = 1, ignore_canstun = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stun"
	if(status_flags & CANSTUN || ignore_canstun)
		stun = max(amount * STUN_TIME_MULTIPLIER,0)
		if(updating)
			update_canmove()
		return TRUE

/mob/proc/AdjustStun(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stun = max(stun + (amount * STUN_TIME_MULTIPLIER),0)
		if(updating)
			update_canmove()
		return TRUE

/////////////////////////////////// KNOCKDOWN ////////////////////////////////////

/mob/proc/Knockdown(amount, updating = 1, ignore_canknockdown = 0)
	if((status_flags & CANKNOCKDOWN) || ignore_canknockdown)
		knockdown = max(max(knockdown,amount * STUN_TIME_MULTIPLIER),0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/mob/proc/SetKnockdown(amount, updating = 1, ignore_canknockdown = 0)
	if(status_flags & CANKNOCKDOWN || ignore_canknockdown)
		knockdown = max(amount * STUN_TIME_MULTIPLIER,0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/mob/proc/AdjustKnockdown(amount, updating = 1, ignore_canknockdown = 0)
	if((status_flags & CANKNOCKDOWN) || ignore_canknockdown)
		knockdown = max(knockdown + (amount * STUN_TIME_MULTIPLIER) ,0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/////////////////////////////////// UNCONSCIOUS ////////////////////////////////////

/mob/proc/Unconscious(amount, updating = TRUE, ignore_canunconscious = FALSE)
	if(status_flags & CANUNCONSCIOUS || ignore_canunconscious)
		var/old_unconscious = unconscious
		unconscious = max(max(unconscious,amount * STUN_TIME_MULTIPLIER),0)
		if((!old_unconscious && unconscious) || (old_unconscious && !unconscious))
			if(updating)
				update_stat()
		return TRUE

/mob/proc/SetUnconscious(amount, updating = TRUE, ignore_canunconscious = FALSE)
	if(status_flags & CANUNCONSCIOUS || ignore_canunconscious)
		var/old_unconscious = unconscious
		unconscious = max(amount * STUN_TIME_MULTIPLIER,0)
		if((!old_unconscious && unconscious) || (old_unconscious && !unconscious))
			if(updating)
				update_stat()
		return TRUE

/mob/proc/AdjustUnconscious(amount, updating = TRUE, ignore_canunconscious = FALSE)
	if(status_flags & CANUNCONSCIOUS || ignore_canunconscious)
		var/old_unconscious = unconscious
		unconscious = max(unconscious + (amount * STUN_TIME_MULTIPLIER) ,0)
		if((!old_unconscious && unconscious) || (old_unconscious && !unconscious))
			if(updating)
				update_stat()
		return TRUE

/////////////////////////////////// SLEEPING ////////////////////////////////////

/mob/living/proc/IsSleeping() //If we're asleep
	return has_status_effect(STATUS_EFFECT_SLEEPING)

/mob/living/proc/AmountSleeping() //How many deciseconds remain in our sleep
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		return world.time - S.duration
	return 0

/mob/living/proc/Sleeping(amount, updating = TRUE) //Can't go below remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		var/remaining_duration = world.time - S.duration
		S.duration = world.time + max(amount, remaining_duration)
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING)
		S.duration = amount
		S.update_canmove = updating
	return S

/mob/living/proc/SetSleeping(amount, updating = TRUE) //Sets remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(amount <= 0)
		if(S)
			S.update_canmove = updating
			qdel(S)
	else
		S = apply_status_effect(STATUS_EFFECT_SLEEPING)
	if(S)
		S.duration = amount
		S.update_canmove = updating
	return S

/mob/living/proc/AdjustSleeping(amount, updating = TRUE) //Adds to remaining duration
	var/datum/status_effect/incapacitating/sleeping/S = IsSleeping()
	if(S)
		S.duration += amount
	else if(amount > 0)
		S = apply_status_effect(STATUS_EFFECT_SLEEPING)
		S.duration = amount
		S.update_canmove = updating
	return S

/////////////////////////////////// RESTING ////////////////////////////////////

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
	update_canmove()

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	update_canmove()

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
	update_canmove()

/////////////////////////////////// JITTERINESS ////////////////////////////////////

/mob/proc/Jitter(amount)
	jitteriness = max(jitteriness,amount,0)

/////////////////////////////////// DIZZINESS ////////////////////////////////////

/mob/proc/Dizzy(amount)
	dizziness = max(dizziness,amount,0)

/////////////////////////////////// EYE DAMAGE ////////////////////////////////////

/mob/proc/damage_eyes(amount)
	return

/mob/proc/adjust_eye_damage(amount)
	return

/mob/proc/set_eye_damage(amount)
	return

/////////////////////////////////// EYE_BLIND ////////////////////////////////////

/mob/proc/blind_eyes(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = max(eye_blind, amount)
		if(!old_eye_blind)
			if(stat == CONSCIOUS)
				throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)

/mob/proc/adjust_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind += amount
		if(!old_eye_blind)
			if(stat == CONSCIOUS)
				throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS || (disabilities & BLIND))
			blind_minimum = 1
		eye_blind = max(eye_blind+amount, blind_minimum)
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")

/mob/proc/set_blindness(amount)
	if(amount>0)
		var/old_eye_blind = eye_blind
		eye_blind = amount
		if(client && !old_eye_blind)
			if(stat == CONSCIOUS)
				throw_alert("blind", /obj/screen/alert/blind)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
	else if(eye_blind)
		var/blind_minimum = 0
		if(stat != CONSCIOUS || (disabilities & BLIND))
			blind_minimum = 1
		eye_blind = blind_minimum
		if(!eye_blind)
			clear_alert("blind")
			clear_fullscreen("blind")

/////////////////////////////////// EYE_BLURRY ////////////////////////////////////

/mob/proc/blur_eyes(amount)
	if(amount>0)
		var/old_eye_blurry = eye_blurry
		eye_blurry = max(amount, eye_blurry)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)

/mob/proc/adjust_blurriness(amount)
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(eye_blurry+amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry && !eye_blurry)
		clear_fullscreen("blurry")

/mob/proc/set_blurriness(amount)
	var/old_eye_blurry = eye_blurry
	eye_blurry = max(amount, 0)
	if(amount>0)
		if(!old_eye_blurry)
			overlay_fullscreen("blurry", /obj/screen/fullscreen/blurry)
	else if(old_eye_blurry)
		clear_fullscreen("blurry")

/////////////////////////////////// DRUGGY ////////////////////////////////////

/mob/proc/adjust_drugginess(amount)
	return

/mob/proc/set_drugginess(amount)
	return

/////////////////////////////////// BLIND DISABILITY ////////////////////////////////////

/mob/proc/cure_blind() //when we want to cure the BLIND disability only.
	return

/mob/proc/become_blind()
	return

/////////////////////////////////// NEARSIGHT DISABILITY ////////////////////////////////////

/mob/proc/cure_nearsighted()
	return

/mob/proc/become_nearsighted()
	return


//////////////////////////////// HUSK DISABILITY ///////////////////////////:

/mob/proc/cure_husk()
	return

/mob/proc/become_husk()
	return







