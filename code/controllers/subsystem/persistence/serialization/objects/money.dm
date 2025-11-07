/obj/item/holochip/get_save_vars()
	. = ..()
	. += NAMEOF(src, credits)

	. -= NAMEOF(src, name)
	return .
