/datum/action/cooldown/eminence/purge_reagents
	name = "Purge Reagents"
	desc = "Purges all reagents from the bloodstream of a marked servant, useful for if they have been given holy water."
	button_icon_state = "Mending Mantra"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/eminence/purge_reagents/Activate(atom/target)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/eminence/em_user = usr
	if(!em_user.marked_servant)
		to_chat(em_user, span_notice("You dont currently have a marked servant!"))
		return FALSE
	var/mob/living/purged = em_user.marked_servant?.resolve()
	for(var/datum/reagent/chem in purged.reagents.reagent_list)
		purged.reagents.remove_reagent(chem.type, chem.volume)
	to_chat(em_user, "You purge the reagents of [purged].")
	em_user.marked_servant = null
	return TRUE
