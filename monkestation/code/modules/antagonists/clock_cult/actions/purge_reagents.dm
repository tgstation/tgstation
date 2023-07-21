/datum/action/cooldown/eminence/purge_reagents
	name = "Purge Reagents"
	desc = "Purges all reagents from the bloodstream of a marked servant, useful for if they have been given holy water."
	button_icon_state = "Mending Mantra"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/eminence/purge_reagents/Activate(atom/target)
	var/mob/living/eminence/em_user = usr
	if(!istype(em_user))
		to_chat(usr, span_boldwarning("You are not an eminence and should not have this! Please report this as a bug."))
		return FALSE

	if(!em_user.marked_servant)
		to_chat(em_user, span_notice("You dont currently have a marked servant!"))
		return FALSE
	var/mob/living/purged = em_user.marked_servant?.resolve()
	for(var/datum/reagent/chem in purged.reagents.reagent_list)
		var/amount = purged.reagents.get_reagent_amount(chem.type)
		purged.reagents.remove_reagent(chem.type, amount)
	to_chat(em_user, "You purge the reagents of [purged].")
	em_user.marked_servant = null
	return TRUE
