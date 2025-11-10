/obj/machinery/light/get_save_vars()
	. = ..()
	. += NAMEOF(src, status)

	. -= NAMEOF(src, icon_state)
	return .

/obj/machinery/light/substitute_with_typepath()
	if(type != /obj/machinery/light)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/built
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return /obj/machinery/light/burned
	return FALSE

/obj/machinery/light/empty/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_BROKEN)
			return /obj/machinery/light/broken
		if(LIGHT_BURNED)
			return /obj/machinery/light/burned
	return FALSE

/obj/machinery/light/broken/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_EMPTY)
			return /obj/machinery/light/empty
		if(LIGHT_BURNED)
			return /obj/machinery/light/burned
	return FALSE

/obj/machinery/light/burned/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light
		if(LIGHT_EMPTY)
			return /obj/machinery/light/empty
		if(LIGHT_BURNED)
			return /obj/machinery/light/burned
	return FALSE

/obj/machinery/light/small/substitute_with_typepath()
	if(type != /obj/machinery/light/small)
		return FALSE

	switch(status)
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/empty
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return /obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/empty/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_BROKEN)
			return /obj/machinery/light/small/broken
		if(LIGHT_BURNED)
			return /obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/broken/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/empty
		if(LIGHT_BURNED)
			return /obj/machinery/light/small/burned
	return FALSE

/obj/machinery/light/small/burned/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/small
		if(LIGHT_EMPTY)
			return /obj/machinery/light/small/empty
		if(LIGHT_BURNED)
			return /obj/machinery/light/small/burned
	return FALSE

// Floor lights
/obj/machinery/light/floor/substitute_with_typepath()
	if(type != /obj/machinery/light/floor)
		return FALSE

	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			return /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			return /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			return obj/machinery/light/floor/burned
	return FALSE

/obj/machinery/light/floor/broken/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			return /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			return /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			return obj/machinery/light/floor/burned
	return FALSE

/obj/machinery/light/floor/burned/substitute_with_typepath()
	switch(status)
		if(LIGHT_OK)
			return /obj/machinery/light/floor
		if(LIGHT_EMPTY)
			return /obj/machinery/light/floor/empty
		if(LIGHT_BROKEN)
			return /obj/machinery/light/floor/broken
		if(LIGHT_BURNED)
			return obj/machinery/light/floor/burned
	return FALSE

/obj/structure/light_construct/get_save_vars()
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)

	. -= NAMEOF(src, icon_state)
	return .
