/turf/open/misc/ashplanet
	icon = 'icons/turf/mining.dmi'
	gender = PLURAL
	name = "ash"
	icon_state = "ash"
	base_icon_state = "ash"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	desc = "The ground is covered in volcanic ash."
	baseturfs = /turf/open/misc/ashplanet/wateryrock //I assume this will be a chasm eventually, once this becomes an actual surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE

	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	rust_resistance = RUST_RESISTANCE_ORGANIC
	var/smooth_icon = 'icons/turf/floors/ash.dmi'

/turf/open/misc/ashplanet/Initialize(mapload)
	. = ..()
	if(smoothing_flags & SMOOTH_BITMASK)
		var/matrix/M = new
		M.Translate(-4, -4)
		transform = M
		icon = smooth_icon
		icon_state = "[icon_state]-[smoothing_junction]"

/turf/open/misc/ashplanet/break_tile()
	return

/turf/open/misc/ashplanet/burn_tile()
	return

/turf/open/misc/ashplanet/ash
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_ASH
	canSmoothWith = SMOOTH_GROUP_FLOOR_ASH + SMOOTH_GROUP_CLOSED_TURFS
	layer = HIGH_TURF_LAYER
	slowdown = 1

/turf/open/misc/ashplanet/rocky
	gender = PLURAL
	name = "rocky ground"
	icon_state = "rockyash"
	base_icon_state = "rocky_ash"
	smooth_icon = 'icons/turf/floors/rocky_ash.dmi'
	layer = MID_TURF_LAYER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_FLOOR_ASH_ROCKY
	canSmoothWith = SMOOTH_GROUP_FLOOR_ASH_ROCKY + SMOOTH_GROUP_CLOSED_TURFS
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/misc/ashplanet/wateryrock
	gender = PLURAL
	name = "wet rocky ground"
	smoothing_flags = NONE
	icon_state = "wateryrock"
	base_icon_state = "wateryrock"
	slowdown = 2
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	rust_resistance = RUST_RESISTANCE_ORGANIC

/turf/open/misc/ashplanet/wateryrock/Initialize(mapload)
	icon_state = "[icon_state][rand(1, 9)]"
	. = ..()
