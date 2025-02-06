/mob/living/carbon/human/get_movespeed_modifiers()
	var/list/considering = ..()
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))
		. = list()
		for(var/id in considering)
			var/datum/movespeed_modifier/M = considering[id]
			if(M.flags & IGNORE_NOSLOW || M.multiplicative_slowdown < 0)
				.[id] = M
		return
	return considering

/mob/living/carbon/human/slip(knockdown_amount, obj/slipped_on, lube_flags, paralyze, daze, force_drop = FALSE)
	if(HAS_TRAIT(src, TRAIT_NO_SLIP_ALL))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_SLIP_WATER) && !(lube_flags & GALOSHES_DONT_HELP))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_SLIP_ICE) && (lube_flags & SLIDE_ICE))
		return FALSE

	return ..()

/mob/living/carbon/human/mob_negates_gravity()
	return dna.species.negates_gravity(src) || ..()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(shoes && body_position == STANDING_UP && has_gravity(loc))
		if((. && !moving_diagonally) || (!. && moving_diagonally == SECOND_DIAG_STEP))
			SEND_SIGNAL(shoes, COMSIG_SHOES_STEP_ACTION)

