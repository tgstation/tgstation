#define COLOR_FLOCK "#3c8c64"

/turf/open/floor/flock // todo: make mineral
	name = "humming substrate"
	desc = "A smooth, warm teal floor covered in flickering circuitry and pulsing lights."
	icon = 'troutstation/icons/turf/floors/flock_floor.dmi'
	icon_state = "flock_floor-255"
	base_icon_state = "flock_floor"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOCK
	canSmoothWith = SMOOTH_GROUP_FLOCK
	footstep = FOOTSTEP_PLATING
	smoothing_junction = 255

	overfloor_placed = FALSE // don't allow this to be simply ripped up with a crowbar

	/// Icon for the emissive overlay
	var/emissive_icon = 'troutstation/icons/turf/floors/flock_floor_e.dmi'
	/// The alpha used for the emissive decal.
	var/emissive_alpha = 50

/turf/open/floor/flock/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/decal, emissive_icon, base_icon_state, dir, EMISSIVE_PLANE, null, emissive_alpha, GLOB.emissive_color, smoothing_junction)

/turf/closed/wall/flock // todo: make mineral
	name = "humming wall"
	desc = "Warm and smooth to the touch, and constantly pulsing with internal light."
	icon = 'troutstation/icons/turf/walls/flock_wall.dmi'
	icon_state = "flock_wall-0"
	base_icon_state = "flock_wall"
	turf_flags = IS_SOLID
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_FLOCK_WALL
	canSmoothWith = SMOOTH_GROUP_FLOCK_WALL
	// todo: other properties when the relevant items exist

	/// Icon for the emissive overlay
	var/emissive_icon = 'troutstation/icons/turf/walls/flock_wall_e.dmi'

/turf/closed/wall/flock/set_smoothed_icon_state(new_junction)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/turf/closed/wall/flock/update_overlays()
	. = ..()
	. += emissive_appearance(emissive_icon, icon_state, src)

// /turf/closed/wall/mineral/cult
// 	name = "runed metal wall"
// 	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
// 	icon = 'icons/turf/walls/cult_wall.dmi'
// 	icon_state = "cult_wall-0"
// 	base_icon_state = "cult_wall"
// 	turf_flags = IS_SOLID
// 	smoothing_flags = SMOOTH_BITMASK
// 	canSmoothWith = null
// 	sheet_type = /obj/item/stack/sheet/runed_metal
// 	sheet_amount = 1
// 	girder_type = /obj/structure/girder/cult

// /turf/closed/wall/mineral/cult/Initialize(mapload)
// 	new /obj/effect/temp_visual/cult/turf(src)
// 	. = ..()

// /turf/closed/wall/mineral/cult/devastate_wall()
// 	new sheet_type(get_turf(src), sheet_amount)

// /turf/closed/wall/mineral/cult/artificer
// 	name = "runed stone wall"
// 	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

// /turf/closed/wall/mineral/cult/artificer/break_wall()
// 	new /obj/effect/temp_visual/cult/turf(get_turf(src))
// 	return null //excuse me we want no runed metal here

// /turf/closed/wall/mineral/cult/artificer/devastate_wall()
// 	new /obj/effect/temp_visual/cult/turf(get_turf(src))




// /turf/closed/indestructible/riveted/hierophant
// 	name = "runic wall"
// 	desc = "A wall made out of strange stone, runes on its sides pulsating in a rythmic pattern."
// 	icon = 'icons/turf/walls/hierophant_wall.dmi'
// 	icon_state = "hierophant_wall-0"
// 	base_icon_state = "hierophant_wall"
// 	smoothing_flags = SMOOTH_BITMASK
// 	smoothing_groups = SMOOTH_GROUP_HIERO_WALL
// 	canSmoothWith = SMOOTH_GROUP_HIERO_WALL


// /turf/closed/indestructible/riveted/hierophant/set_smoothed_icon_state(new_junction)
// 	. = ..()
// 	update_appearance(UPDATE_OVERLAYS)

// /turf/closed/indestructible/riveted/hierophant/update_overlays()
// 	. = ..()
// 	. += emissive_appearance('icons/turf/walls/hierophant_wall_e.dmi', icon_state, src)

#undef COLOR_FLOCK
