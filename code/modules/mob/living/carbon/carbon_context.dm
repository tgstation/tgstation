/mob/living/carbon/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if (!isnull(held_item))
		return .

	if (!ishuman(user))
		return .

	var/mob/living/carbon/human/human_user = user

	if (human_user.combat_mode)
		context[SCREENTIP_CONTEXT_LMB] = "Attack"
	else if (human_user == src)
		context[SCREENTIP_CONTEXT_LMB] = "Check injuries"

		if (get_bodypart(human_user.zone_selected)?.get_bleed_rate())
			context[SCREENTIP_CONTEXT_CTRL_LMB] = "Grab limb"

	if (human_user != src)
		context[SCREENTIP_CONTEXT_RMB] = "Shove"

		if (body_position == STANDING_UP)
			context[SCREENTIP_CONTEXT_LMB] = "Comfort"
		else if (health >= 0 && !HAS_TRAIT(src, TRAIT_FAKEDEATH))
			context[SCREENTIP_CONTEXT_LMB] = "Shake"
		else
			context[SCREENTIP_CONTEXT_LMB] = "CPR"

	return CONTEXTUAL_SCREENTIP_SET
