/datum/asset/spritesheet_batched/slot_machines
	name = "slotmachines"

/datum/asset/spritesheet_batched/slot_machines/create_spritesheets()
	// initialising the list of items we need
	var/list/target_items = list()
	for(var/obj/machinery/computer/slot_machine/slot_machine as anything in typesof(/obj/machinery/computer/slot_machine))
		slot_machine = new slot_machine()
		target_items |= slot_machine.symbol_paths // no dupes
		qdel(slot_machine)

	for(var/atom/atom as anything in target_items)
		var/icon = initial(atom.icon)
		var/icon_state = initial(atom.icon_state)
		var/id = sanitize_css_class_name("[icon][icon_state]")

		var/has_gags = atom::greyscale_config && atom::greyscale_colors
		var/has_color = atom::color && icon_state
		// GAGS and colored icons must be pregenerated so blacklist them for now
		if(has_gags || has_color)
			stack_trace("[atom] is either using GAGS or colored icons which is not supported for slot machine reels")
			continue

		insert_icon(id, uni_icon(icon, icon_state))
