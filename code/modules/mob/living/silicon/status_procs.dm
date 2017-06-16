
//Here are the procs used to modify status effects of a mob.
//The effects include: paralysis, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, BLIND disability, and NEARSIGHT disability.

/////////////////////////////////// PARALYSIS ////////////////////////////////////

/mob/living/silicon/Paralyse(amount, updating = 1, ignore_canparalyse = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/SetParalysis(amount, updating = 1, ignore_canparalyse = 0)
	. = ..()
	if(. && updating)
		update_stat()

/mob/living/silicon/AdjustParalysis(amount, updating = 1, ignore_canparalyse = 0)
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
