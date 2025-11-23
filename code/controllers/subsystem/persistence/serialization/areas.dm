/area/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, lightswitch) // lightswitches use this area variable to save their state
	return .
