/obj/machinery/light/get_save_vars()
	. = ..()
	. += NAMEOF(src, status)

	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/light/get_save_substitute_type()
	if(type != /obj/machinery/light)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/built
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/built/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_EMPTY)
			return /obj/machinery/light/built
		if(LIGHT_BURNED)
			return //obj/machinery/light/burned
	return FALSE

/obj/machinery/light/small/get_save_substitute_type()
	if(type != /obj/machinery/light/small)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/built
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/built/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/built
		if(LIGHT_BURNED)
			return //obj/machinery/light/small/burned
	return FALSE

// Floor lights
/obj/machinery/light/floor/get_save_substitute_type()
	if(type != /obj/machinery/light/floor)
		return FALSE

	switch(status)
		if(LIGHT_BROKEN)
			return /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			return //obj/machinery/light/floor/burned
		// LIGHT_EMPTY - no /built subtype exists yet for floor lights
	return FALSE

/obj/machinery/light/floor/broken/get_save_substitute_type()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/floor
		if(LIGHT_BURNED)
			return //obj/machinery/light/floor/burned
		// LIGHT_EMPTY - no /built subtype exists yet for floor lights
	return FALSE

/obj/structure/light_construct/get_save_vars()
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)

	. -= NAMEOF(src, icon_state)
	return .
