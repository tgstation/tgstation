//Used to access the Psi Web to buy abilities.
//Accesses the Psi Web, which umbrages use to purchase abilities using lucidity. Lucidity is drained from people using the Devour Will ability.
/datum/action/innate/darkspawn/psi_web
	name = "Psi Web"
	id = "psi_web"
	desc = "Access the Mindlink directly to unlock and upgrade your supernatural powers."
	button_icon_state = "psi_web"
	check_flags = AB_CHECK_CONSCIOUS
	blacklisted = TRUE
	psi_cost = 0

/datum/action/innate/darkspawn/psi_web/Activate()
	to_chat(usr, "<span class='velvet bold'>You retreat inwards and touch the Mindlink...</span>")
	if(!darkspawn)
		return
	darkspawn.ui_interact(usr)
	return TRUE
