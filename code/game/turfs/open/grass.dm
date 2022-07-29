/turf/open/misc/grass
	name = "grass"
	desc = "A patch of grass."
	icon = 'icons/turf/floors.dmi'
	icon_state = "grass0"
	base_icon_state = "grass"
	baseturfs = /turf/open/misc/sandy_dirt
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_FLOOR_GRASS)
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_FLOOR_GRASS)
	layer = HIGH_TURF_LAYER
	var/damaged_dmi = 'icons/turf/floors/grass.dmi'
	var/smooth_icon = 'icons/turf/floors/grass.dmi'

/turf/open/misc/grass/break_tile()
	. = ..()
	icon_state = "damaged"

/turf/open/misc/grass/Initialize(mapload)
	. = ..()
	if(smoothing_flags)
		var/matrix/translation = new
		translation.Translate(-9, -9)
		transform = translation
		icon = smooth_icon

/turf/open/misc/grass/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
