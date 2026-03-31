/datum/asset/spritesheet_batched/slot_machines
	name = "slot machines"

/datum/asset/spritesheet_batched/slot_machines/create_spritesheets()
	// initialising the list of items we need
	var/list/target_items = list()
	for(var/obj/machinery/computer/slot_machine/slot_machine as anything in subtypesof(/obj/machinery/computer/slot_machine))
		slot_machine = new slot_machine()
		target_items |= slot_machine.symbol_paths
		qdel(slot_machine)

	var/list/id_list = list()
	for(var/atom/item as anything in target_items)
		if(!ispath(item, /atom))
			continue

		var/icon = initial(item.icon)
		var/icon_state = initial(item.icon_state)
		if(ispath(item, /obj))
			var/obj/obj_atom = item
			if(initial(obj_atom.icon_state_preview))
				icon_state = initial(obj_atom.icon_state_preview)

		var/id = sanitize_css_class_name("[icon][icon_state]")
		if(id in id_list) //no dupes
			continue
		id_list += id
		insert_icon(id, uni_icon(icon, icon_state))

