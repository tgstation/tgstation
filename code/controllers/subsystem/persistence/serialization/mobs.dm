/mob/living/basic/dark_wizard/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	return .
