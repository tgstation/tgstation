ADMIN_CONTEXT_ENTRY(contexxt_machine_upgrade, "Tweak Component Ratings", R_DEBUG, obj/machinery/machine in world)
	if(!length(machine.component_parts))
		to_chat(usr, span_warning("[machine] has no components!"))
		return

	var/new_rating = input(usr, "Enter new rating:","Num") as num|null
	if(!new_rating)
		return
	for(var/obj/item/stock_parts/part in machine.component_parts)
		part.rating = new_rating
	for(var/datum/stock_part/datum_part in machine.component_parts)
		machine.component_parts -= datum_part
		var/obj/item/stock_parts/new_part = new datum_part.physical_object_type
		new_part.rating = new_rating
		machine.component_parts += new_part
	machine.RefreshParts()
