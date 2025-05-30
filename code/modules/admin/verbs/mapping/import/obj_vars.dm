/obj/machinery/ore_silo/restore_saved_value(attribute, resolved_value)
	if(attribute == "materials")
		for(var/material_id in resolved_value)
			materials.insert_amount_mat(resolved_value[material_id], text2path(material_id))

/obj/structure/closet/restore_saved_value(attribute, resolved_value)
	//the maploader flattens reccursive contents out on the turf(e.g. like a backpack having stuff but its inside the closet)
	//but closets on init takes everything on the turf even stuff that does not belong to it
	//so we move out stuff that isnt ours
	if(attribute == "contents")
		var/atom/drop = drop_location()
		for(var/obj/thing in contents)
			if(!(thing in resolved_value))
				thing.forceMove(drop)

		return

	..()
