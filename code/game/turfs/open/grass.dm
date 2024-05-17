/turf/open/misc/grass
	name = "grass"
	desc = "A patch of grass."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass"
	base_icon_state = "grass"
	baseturfs = /turf/open/misc/sandy_dirt
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BROKEN_TURF | SMOOTH_BURNT_TURF
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_GRASS
	canSmoothWith = SMOOTH_GROUP_FLOOR_GRASS + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	rust_resistance = RUST_RESISTANCE_ORGANIC
	damaged_dmi = 'icons/turf/floors/grass_damaged.dmi'
	/// The icon used for smoothing.
	var/smooth_icon = 'icons/turf/floors/grass.dmi'
	/// The base icon_state for the broken state.
	var/base_broken_icon_state = "grass_damaged"
	/// The base icon_state for the burnt state.
	var/base_burnt_icon_state = "grass_damaged"

/turf/open/misc/grass/broken_states()
	if (!smoothing_junction || !(smoothing_flags & SMOOTH_BROKEN_TURF))
		return list("[base_broken_icon_state]-255")

	return list("[base_broken_icon_state]-[smoothing_junction]")

/turf/open/misc/grass/burnt_states()
	if (!smoothing_junction || !(smoothing_flags & SMOOTH_BURNT_TURF))
		return list("[base_burnt_icon_state]-255")

	return list("[base_burnt_icon_state]-[smoothing_junction]")

/turf/open/misc/grass/Initialize(mapload)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(LARGE_TURF_SMOOTHING_X_OFFSET, LARGE_TURF_SMOOTHING_Y_OFFSET)
		transform = translation
		icon = smooth_icon

	if(is_station_level(z))
		GLOB.station_turfs += src


/turf/open/misc/grass/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	if (!.)
		return

	if(!smoothing_flags)
		return

	underlay_appearance.transform = transform


/turf/open/misc/grass/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
