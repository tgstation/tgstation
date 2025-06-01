
/obj/get_save_vars()
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)

/obj/item/get_save_vars()
	. = ..()
	if(contents.len && atom_storage)
		. += NAMEOF(src, contents)

/obj/item/stack/get_save_vars()
	. = ..()
	. += NAMEOF(src, amount)

/obj/docking_port/get_save_vars()
	. = ..()
	. += NAMEOF(src, dheight)
	. += NAMEOF(src, dwidth)
	. += NAMEOF(src, height)
	. += NAMEOF(src, shuttle_id)
	. += NAMEOF(src, width)

/obj/machinery/ore_silo/get_save_vars()
	. = ..()

	var/list/material_list = materials.materials
	var/list/material_list_string = list()
	for(var/datum/material/mat in material_list)
		if(!material_list[mat])
			continue
		material_list_string["[mat.type]"] = material_list[mat]
	if(!material_list_string.len)
		return

	. += list(list("materials" = material_list_string))

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/docking_port/stationary/get_save_vars()
	. = ..()
	. += NAMEOF(src, roundstart_template)

/obj/item/stock_parts/power_store/get_save_vars()
	. = ..()
	. += NAMEOF(src, charge)
	. += NAMEOF(src, rigged)
	return .

/obj/item/photo/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)

/obj/effect/decal/cleanable/blood/footprints/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
