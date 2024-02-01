/datum/scripture/abscond
	name = "Abscond"
	desc = "Recalls you and anyone you are dragging to reebe."
	tip = "If using this with a prisoner dont forget to cuff them first."
	button_icon_state = "Abscond"
	invocation_time = 3 SECONDS
	invocation_text = list("Return to our home, the city of cogs.")
	category = SPELLTYPE_SERVITUDE
	power_cost = 5

/datum/scripture/abscond/invoke_success()
	try_servant_warp(invoker, get_turf(pick(GLOB.abscond_markers)))
