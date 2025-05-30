
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

/obj/machinery/atmospherics/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/item/pipe/get_save_vars()
	. = ..()
	. += NAMEOF(src, piping_layer)
	. += NAMEOF(src, pipe_color)

/obj/structure/closet/get_save_vars()
	. = ..()
	. += NAMEOF(src, opened)
	. += NAMEOF(src, contents_initialized)
	//basically if this closet has never been opened then don't save its contents cause it will spawn its own stuff
	if(!opened && contents_initialized)
		. += NAMEOF(src, contents)
