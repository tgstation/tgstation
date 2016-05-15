
//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// STUNNED ////////////////////////////////////

/mob/living/silicon/Stun(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
		if(updating)
			update_stat()

/mob/living/silicon/AdjustStunned(amount, updating = 1, ignore_canstun = 0)
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(stunned + amount,0)
		if(updating)
			update_stat()

/mob/living/silicon/SetStunned(amount, updating = 1, ignore_canstun = 0) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(status_flags & CANSTUN || ignore_canstun)
		stunned = max(amount,0)
		if(updating)
			update_stat()

/////////////////////////////////// WEAKENED ////////////////////////////////////

/mob/living/silicon/Weaken(amount, updating = 1, ignore_canweaken = 0)
	if(status_flags & CANWEAKEN || ignore_canweaken)
		weakened = max(max(weakened,amount),0)
		if(updating)
			update_stat()

/mob/living/silicon/AdjustWeakened(amount, updating = 1, ignore_canweaken = 0)
	if(status_flags & CANWEAKEN || ignore_canweaken)
		weakened = max(weakened + amount,0)
		if(updating)
			update_stat()

/mob/living/silicon/SetWeakened(amount, updating = 1, ignore_canweaken = 0)
	if(status_flags & CANWEAKEN || ignore_canweaken)
		weakened = max(amount,0)
		if(updating)
			update_stat()

/////////////////////////////////// EAR DAMAGE ////////////////////////////////////

/mob/living/silicon/adjustEarDamage()
	return

/mob/living/silicon/setEarDamage()
	return