
//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// STUN ////////////////////////////////////

/mob/living/silicon/Stun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/SetStun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/AdjustStun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
	if(. && updating)
		update_stat()

/////////////////////////////////// KNOCKDOWN ////////////////////////////////////

/mob/living/silicon/Knockdown(amount, updating = 1, ignore_canknockdown = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/SetKnockdown(amount, updating = 1, ignore_canknockdown = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/AdjustKnockdown(amount, updating = 1, ignore_canknockdown = 0)
	. = ..()
	if(. && updating)
		update_stat()
