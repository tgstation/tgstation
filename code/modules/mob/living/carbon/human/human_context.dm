/mob/living/carbon/human/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if (!ishuman(user))
		return .

	if (user == src)
		return .

	if (pulledby == user)
		switch (user.grab_state)
			if (GRAB_PASSIVE)
				context[SCREENTIP_CONTEXT_CTRL_LMB] = "Grip"
			if (GRAB_AGGRESSIVE)
				context[SCREENTIP_CONTEXT_CTRL_LMB] = "Choke"
			if (GRAB_NECK)
				context[SCREENTIP_CONTEXT_CTRL_LMB] = "Strangle"
			else
				return .
	else
		context[SCREENTIP_CONTEXT_CTRL_LMB] = "Pull"

	return CONTEXTUAL_SCREENTIP_SET
