/obj/item/holochip/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, credits)
	return .
