/obj/effect/landmark/is_saveable(turf/current_loc, list/obj_blacklist)
	// most landmarks get deleted except for latejoin arrivals shuttle
	return TRUE

/obj/effect/decal/is_saveable(turf/current_loc, list/obj_blacklist)
	. = ..()
	// this shouldn't be possible but just in case
	return !isgroundlessturf(current_loc)

/obj/effect/decal/cleanable/crayon/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, name)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, do_icon_rotate)
	. += NAMEOF(src, rotation)
	. += NAMEOF(src, paint_colour)
	. += NAMEOF(src, color_strength)
	return .

/obj/effect/decal/cleanable/blood/get_save_vars(save_flags=ALL)
	. = ..()
	// check to see if these work otherwise omit it
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, base_icon_state)

	. += NAMEOF(src, bloodiness)
	. += NAMEOF(src, dried)
	return .
