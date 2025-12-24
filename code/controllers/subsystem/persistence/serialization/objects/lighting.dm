/obj/machinery/light/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, status)
	return .

/obj/structure/light_construct/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stage)
	. += NAMEOF(src, fixture_type)
	return .
