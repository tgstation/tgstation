/obj/machinery/light/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, status)
	return .

/* This feels like a mistake in hindsight

/obj/machinery/light/substitute_with_typepath(map_string)
	if(type != /obj/machinery/light)
		return FALSE

	var/typepath
	switch(status)
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/empty
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/empty/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/broken/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/empty
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/burned/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/empty
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/small/substitute_with_typepath(map_string)
	if(type != /obj/machinery/light/small)
		return FALSE

	var/typepath
	switch(status)
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/small/empty
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/small/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/small/empty/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/small
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/small/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/small/broken/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/small
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/small/empty
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/small/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/small/burned/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/small
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/small/empty
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/small/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

// Floor lights
/obj/machinery/light/floor/substitute_with_typepath(map_string)
	if(type != /obj/machinery/light/floor)
		return FALSE

	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/floor/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/floor/broken/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/floor/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath

/obj/machinery/light/floor/burned/substitute_with_typepath(map_string)
	var/typepath
	switch(status)
		if(LIGHT_OK)
			typepath = /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			typepath = /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			typepath = /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			typepath = /obj/machinery/light/floor/burned

	TGM_MAP_BLOCK(map_string, typepath, null)
	return typepath
*/

/obj/structure/light_construct/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)
	return .
