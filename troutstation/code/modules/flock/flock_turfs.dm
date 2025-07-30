/turf/open/floor/flock
	name = "humming substrate"
	desc = "A smooth, warm teal floor covered in flickering circuitry and pulsing lights."
	icon = 'troutstation/icons/turf/floors/flock_floor.dmi'
	icon_state = "flock_floor-255"
	base_icon_state = "flock_floor"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOCK
	canSmoothWith = SMOOTH_GROUP_FLOCK
	footstep = FOOTSTEP_PLATING

	overfloor_placed = FALSE // don't allow this to be simply ripped up with a crowbar

	/// Icon for the emissive overlay
	//var/emissive_icon = 'icons/turf/floors/hierophant_floor_e.dmi'

/turf/open/floor/flock/set_smoothed_icon_state(new_junction)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

// /turf/open/floor/flock/update_overlays()
// 	. = ..()
// 	. += emissive_appearance(emissive_icon, icon_state, src)
