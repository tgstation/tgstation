/datum/action/cooldown/sneak/spider
	name = "Sneak"
	desc = "Blend into the webs to stalk your prey."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "web_sneak"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED
	/// The alpha we go to when sneaking.

/datum/action/cooldown/sneak/spider/Remove(mob/living/remove_from)
	if(HAS_TRAIT(remove_from, TRAIT_SNEAK))
		remove_from.alpha = initial(remove_from.alpha)
		REMOVE_TRAIT(remove_from, TRAIT_SNEAK, name)

	return ..()

/datum/action/cooldown/sneak/spider/Activate(atom/target)
	if(HAS_TRAIT(owner, TRAIT_SNEAK))
		// It's safest to go to the initial alpha of the mob.
		// Otherwise we get permanent invisbility exploits.
		owner.alpha = initial(owner.alpha)
		to_chat(owner, span_noticealien("You reveal yourself!"))
		REMOVE_TRAIT(owner, TRAIT_SNEAK, name)

	else
		owner.alpha = sneak_alpha
		to_chat(owner, span_noticealien("You blend into the webs..."))
		ADD_TRAIT(owner, TRAIT_SNEAK, name)

	return TRUE
