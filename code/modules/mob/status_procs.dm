
//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// STUNNED ////////////////////////////////////

/mob/proc/Stun(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		if(updating)
			update_canmove()
		return TRUE

/mob/proc/SetStunned(amount, updating = 1, ignore_canstun = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(amount,0)
		if(updating)
			update_canmove()
		return TRUE

/mob/proc/AdjustStunned(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(stunned + amount,0)
		if(updating)
			update_canmove()
		return TRUE

/////////////////////////////////// WEAKENED ////////////////////////////////////

/mob/proc/Weaken(amount, updating = 1, ignore_canweaken = 0)
	if((status_flags & CANWEAKEN) || ignore_canweaken)
		weakened = max(max(weakened,amount),0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/mob/proc/SetWeakened(amount, updating = 1, ignore_canweaken = 0)
	if(status_flags & CANWEAKEN)
		weakened = max(amount,0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/mob/proc/AdjustWeakened(amount, updating = 1, ignore_canweaken = 0)
	if((status_flags & CANWEAKEN) || ignore_canweaken)
		weakened = max(weakened + amount,0)
		if(updating)
			update_canmove()	//updates lying, canmove and icons
		return TRUE

/////////////////////////////////// PARALYSIS ////////////////////////////////////

/mob/proc/Paralyse(amount, updating = 1, ignore_canparalyse = 0)
	if(status_flags & CANPARALYSE || ignore_canparalyse)
		var/old_paralysis = paralysis
		paralysis = max(max(paralysis,amount),0)
		if((!old_paralysis && paralysis) || (old_paralysis && !paralysis))
			if(updating)
				update_stat()
		return TRUE

/mob/proc/SetParalysis(amount, updating = 1, ignore_canparalyse = 0)
	if(status_flags & CANPARALYSE || ignore_canparalyse)
		var/old_paralysis = paralysis
		paralysis = max(amount,0)
		if((!old_paralysis && paralysis) || (old_paralysis && !paralysis))
			if(updating)
				update_stat()
		return TRUE

/mob/proc/AdjustParalysis(amount, updating = 1, ignore_canparalyse = 0)
	if(status_flags & CANPARALYSE || ignore_canparalyse)
		var/old_paralysis = paralysis
		paralysis = max(paralysis + amount,0)
		if((!old_paralysis && paralysis) || (old_paralysis && !paralysis))
			if(updating)
				update_stat()
		return TRUE

/////////////////////////////////// SLEEPING ////////////////////////////////////

/mob/proc/Sleeping(amount, updating = 1, no_alert = FALSE)
	var/old_sleeping = sleeping
	sleeping = max(max(sleeping,amount),0)
	if(!old_sleeping && sleeping)
		if(!no_alert)
			throw_alert("asleep", /obj/screen/alert/asleep)
		if(updating)
			update_stat()
	else if(old_sleeping && !sleeping)
		clear_alert("asleep")
		if(updating)
			update_stat()

/mob/proc/SetSleeping(amount, updating = 1, no_alert = FALSE)
	var/old_sleeping = sleeping
	sleeping = max(amount,0)
	if(!old_sleeping && sleeping)
		if(!no_alert)
			throw_alert("asleep", /obj/screen/alert/asleep)
		if(updating)
			update_stat()
	else if(old_sleeping && !sleeping)
		clear_alert("asleep")
		if(updating)
			update_stat()

/mob/proc/AdjustSleeping(amount, updating = 1, no_alert = FALSE)
	var/old_sleeping = sleeping
	sleeping = max(sleeping + amount,0)
	if(!old_sleeping && sleeping)
		if(!no_alert)
			throw_alert("asleep", /obj/screen/alert/asleep)
		if(updating)
			update_stat()
	else if(old_sleeping && !sleeping)
		clear_alert("asleep")
		if(updating)
			update_stat()

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

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////

/mob/proc/adjustEarDamage()
	return

/mob/proc/setEarDamage()
	return

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







