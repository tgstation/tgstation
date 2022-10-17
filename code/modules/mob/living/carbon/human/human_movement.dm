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

/mob/living/carbon/human/slip(knockdown_amount, obj/O, lube, paralyze, forcedrop)
	if(HAS_TRAIT(src, TRAIT_NOSLIPALL))
		return FALSE
	if (!(lube & GALOSHES_DONT_HELP))
		if(HAS_TRAIT(src, TRAIT_NOSLIPWATER))
			return FALSE
		if(shoes && isclothing(shoes))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP)
				return FALSE
	if (lube & SLIDE_ICE)
		if(shoes && isclothing(shoes))
			var/obj/item/clothing/CS = shoes
			if (CS.clothing_flags & NOSLIP_ICE)
				return FALSE
	return ..()

/mob/living/carbon/human/mob_negates_gravity()
	return dna.species.negates_gravity(src) || ..()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(shoes && body_position == STANDING_UP && loc == NewLoc && has_gravity(loc))
		SEND_SIGNAL(shoes, COMSIG_SHOES_STEP_ACTION)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(movement_type & FLYING || HAS_TRAIT(src, TRAIT_FREE_FLOAT_MOVEMENT))
		return TRUE
	return ..()
