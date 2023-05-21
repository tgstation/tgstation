/datum/action/cooldown/sneak
	name = "Sneak"
	desc = "Sneak into the enviorment."
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "sniper_zoom"
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_INCAPACITATED
	/// The alpha we go to when sneaking.
	var/sneak_alpha = 75

/datum/action/cooldown/sneak/Remove(mob/living/remove_from)
	if(HAS_TRAIT(remove_from, TRAIT_SNEAK))
		remove_from.alpha = initial(remove_from.alpha)
		REMOVE_TRAIT(remove_from, TRAIT_SNEAK, name)

	return ..()

/datum/action/cooldown/sneak/Activate(atom/target)
	if(HAS_TRAIT(owner, TRAIT_SNEAK))
		// It's safest to go to the initial alpha of the mob.
		// Otherwise we get permanent invisbility exploits.
		owner.alpha = initial(owner.alpha)
		to_chat(owner, span_noticealien("You reveal yourself!"))
		REMOVE_TRAIT(owner, TRAIT_SNEAK, name)

	else
		owner.alpha = sneak_alpha
		to_chat(owner, span_noticealien("You blend into the enviorment..."))
		ADD_TRAIT(owner, TRAIT_SNEAK, name)

	return TRUE
