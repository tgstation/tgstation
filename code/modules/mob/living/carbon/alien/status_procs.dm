//Here are the procs used to modify status effects of a mob.
//The effects include: paralysis, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// PARALYSIS ////////////////////////////////////

/mob/living/carbon/alien/Paralyse(amount, updating = 1, ignore_canparalyse = 0)
	. = ..()
	if(!.)
		move_delay_add = min(move_delay_add + round(amount / 2), 10) //a maximum delay of 10

/mob/living/carbon/alien/SetParalysis(amount, updating = 1, ignore_canparalyse = 0)
	. = ..()
	if(!.)
		move_delay_add = min(move_delay_add + round(amount / 2), 10)

/mob/living/carbon/alien/AdjustParalysis(amount, updating = 1, ignore_canparalyse = 0)
	. = ..()
	if(!.)
		move_delay_add = Clamp(move_delay_add + round(amount/2), 0, 10)
