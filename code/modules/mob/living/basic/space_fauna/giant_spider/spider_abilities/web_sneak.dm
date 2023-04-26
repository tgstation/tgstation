/// Camouflage yourseld within the webs to surprise prey
/datum/action/cooldown/alien/sneak
	name = "Web_Sneak"
	desc = "Blend into the webs to stalk your prey."
	button_icon_state = "web_sneak"
	/// The alpha we go to when sneaking.
	var/sneak_alpha = 75

/datum/action/cooldown/alien/sneak/Remove(mob/living/remove_from)
	if(HAS_TRAIT(remove_from, TRAIT_WEN_SNEAK))
		remove_from.alpha = initial(remove_from.alpha)
		REMOVE_TRAIT(remove_from, TRAIT_WEB_SNEAK, name)

	return ..()

/datum/action/cooldown/alien/sneak/Activate(atom/target)
	if(HAS_TRAIT(owner, TRAIT_WEB_SNEAK))
		// It's safest to go to the initial alpha of the mob.
		// Otherwise we get permanent invisbility exploits.
		owner.alpha = initial(owner.alpha)
		to_chat(owner, span_noticealien("You reveal yourself!"))
		REMOVE_TRAIT(owner, TRAIT_WEB_SNEAK, name)

	else
		owner.alpha = sneak_alpha
		to_chat(owner, span_noticealien("You blend into the webs..."))
		ADD_TRAIT(owner, TRAIT_WEB_SNEAK, name)

	return TRUE