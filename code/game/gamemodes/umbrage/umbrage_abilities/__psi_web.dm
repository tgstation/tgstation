//Accesses the Psi Web, which umbrages use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/action/innate/umbrage/psi_web
	name = "Psi Web"
	id = "psi_web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "umbrage_psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = 1
	psi_cost = 0

/datum/action/innate/umbrage/psi_web/Activate()
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	if(!linked_umbrage)
		return
	linked_umbrage.ui_interact(usr)
	return TRUE
