/**
 * List of variables to include when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Do NOT return variable values or custom data in this proc.
 * To save calculated values or custom data, use either get_custom_save_vars() or on_object_saved()
 *
 * Returns: A list of variable names (strings) to be serialized.
 */
/atom/proc/get_save_vars()
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

	return .

/atom/movable/get_save_vars()
	. = ..()
	. += NAMEOF(src, anchored)
	return .

/obj/get_save_vars()
	. = ..()
	. += NAMEOF(src, req_access)
	. += NAMEOF(src, id_tag)
	return .

/**
 * Overrides the variables of an object with a custom value when it is serialized.
 *
 * Always use NAMEOF(src, varname) for the keys to ensure compile-time checking.
 * Examples:
 * - Saving a object reference as a savable id_tag
 * - Saving a calculated value
 *
 * Returns: A named list of variables with their custom values that will be serialized
 */
/atom/proc/get_custom_save_vars()
	return list()

/**
 * A procedure for saving non-standard properties of an object.
 * Examples:
 * - Saving material stacks (ie. ore in a silo)
 * - Saving variables that can be shown as mapping helpers (ie. welded airlock mapping helper)
 * - Saving objects inside of another object (ie. paper inside a noticeboard)
 */
/obj/proc/on_object_saved()
	return null

/**
 * Check if an atom is savable for serilization during map export.
 *
 * For atoms that will always be blacklisted do NOT use this proc. Use the blacklist in map_writer.dm
 * Examples:
 * - [/obj/machinery/atmospherics/components/unary] spawns beneath cryo tubes that causes duplication
 */
/atom/proc/is_saveable()
	return TRUE

/**
 * Check if an atom type has a substitute type for map export serialization.
 *
 * Substitution compacts map data by replacing with a more specific or parent type, which can improve
 * serialization speed. Ensure the substitute type has compatible vars and data. Data transfer is attempted
 * via get_save_vars(), get_custom_save_vars(), and on_object_saved(). Override these procs with an empty
 * list if data transfer is not desired.
 *
 * Examples:
 * ORIGINAL: /obj/machinery/atmospherics/pipe/smart/simple {color="#FF0000", hide=TRUE, pipe_layer=4}
 * SUBSTITUTE: /obj/machinery/atmospherics/pipe/smart/manifold4w/scrubber/hidden/layer4
 * ORIGINAL: /obj/machinery/light/built {icon_state="tube", status=LIGHT_OK}
 * SUBSTITUTE: /obj/machinery/light
 * ORIGINAL: /obj/machinery/atmospherics/components/unary/vent_scrubber {on=TRUE, layer=2}
 * SUBSTITUTE: /obj/machinery/atmospherics/components/unary/vent_scrubber/on/layer2
 *
 * Returns: The typepath for the substitution, or FALSE if no substitute is used.
 */
/atom/proc/get_save_substitute_type()
	return FALSE
