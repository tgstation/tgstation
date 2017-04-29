
//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// STUNNED ////////////////////////////////////

/mob/living/silicon/Stun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/SetStunned(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/AdjustStunned(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/////////////////////////////////// WEAKENED ////////////////////////////////////

/mob/living/silicon/Weaken(amount, updating = 1, ignore_canweaken = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/SetWeakened(amount, updating = 1, ignore_canweaken = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/AdjustWeakened(amount, updating = 1, ignore_canweaken = 0)
	. = ..()
	if(. && updating)
		update_stat()
