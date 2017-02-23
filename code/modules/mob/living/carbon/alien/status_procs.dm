//Here are the procs used to modify status effects of a mob.
//The effects include: stunned, weakened, paralysis, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// STUNNED ////////////////////////////////////

/mob/living/carbon/alien/Stun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(!.)
		move_delay_add = min(move_delay_add + round(amount / 2), 10) //a maximum delay of 10

/mob/living/carbon/alien/SetStunned(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(!.)
		move_delay_add = min(move_delay_add + round(amount / 2), 10)

/mob/living/carbon/alien/AdjustStunned(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(!.)
		move_delay_add = min(move_delay_add + round(amount / 2), 10)
