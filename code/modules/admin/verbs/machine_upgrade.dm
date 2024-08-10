ADMIN_VERB(machine_upgrade, R_DEBUG, "Tweak Component Ratings", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN)
	var/list/machines = list()
	for (var/obj/machinery/target in world)
		machines += target

	var/obj/machinery/machine = tgui_input_list(user, "", "Tweak Component Ratings", machines)
	if (isnull(machine))
		return

	var/new_rating = tgui_input_number(user, "", "Enter new rating:")
	if(new_rating && machine.component_parts)
		for(var/obj/item/stock_parts/P in machine.component_parts)
			P.rating = new_rating
		machine.RefreshParts()
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Machine Upgrade", "[new_rating]")) // If you are copy-pasting this, ensure the 4th parameter is unique to the new proc!
