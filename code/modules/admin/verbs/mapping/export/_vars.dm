/**
 * Retuns a list of vars that are to be saved during map export
 * You can save object vars as well but they have to restored in /atom/restore_saved_value()
 * Custom variables can also be sent in the format list(name = value) which also have to restored in /atom/restore_saved_value()
 */
/atom/proc/get_save_vars()
	SHOULD_CALL_PARENT(TRUE)

	. = list()
	. += NAMEOF(src, color)
	. += NAMEOF(src, dir)
	. += NAMEOF(src, icon)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, name)
	. += NAMEOF(src, pixel_x)
	. += NAMEOF(src, pixel_y)
	. += NAMEOF(src, density)
	. += NAMEOF(src, opacity)

	if(uses_integrity)
		if(atom_integrity != max_integrity) // Only save if atom_integrity differs from max_integrity to avoid redundant saving
			. += NAMEOF(src, atom_integrity)
		. += NAMEOF(src, max_integrity)
		. += NAMEOF(src, integrity_failure)
		. += NAMEOF(src, damage_deflection)
		. += NAMEOF(src, resistance_flags)

/atom/movable/get_save_vars()
	. = ..()
	. += NAMEOF(src, anchored)

/turf/open/get_save_vars()
	. = ..()
	var/datum/gas_mixture/turf_gasmix = return_air()
	initial_gas_mix = turf_gasmix.to_string()
	. += NAMEOF(src, initial_gas_mix)

/mob/living/basic/dark_wizard/get_save_vars()
	. = ..()
	. -= NAMEOF(src, icon_state)
