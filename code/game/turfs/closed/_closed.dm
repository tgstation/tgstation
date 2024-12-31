/turf/closed
	layer = CLOSED_TURF_LAYER
	plane = WALL_PLANE
	turf_flags = IS_SOLID
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	rad_insulation = RAD_MEDIUM_INSULATION
	pass_flags_self = PASSCLOSEDTURF

/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/examine_descriptor(mob/user)
	return "wall"
