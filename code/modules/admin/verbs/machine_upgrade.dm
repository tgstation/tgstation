ADMIN_VERB_AND_CONTEXT_MENU(machine_upgrade, R_DEBUG, "Tweak Component Ratings", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, obj/machinery/machine in world)
	var/new_rating = tgui_input_number(user, "", "Enter new rating:")
	if(new_rating && machine.component_parts)
		for(var/obj/item/stock_parts/P in machine.component_parts)
			P.rating = new_rating
		machine.RefreshParts()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[new_rating]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
