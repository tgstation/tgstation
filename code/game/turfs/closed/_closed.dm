/turf/closed
	plane = GAME_PLANE
	layer = CLOSED_TURF_LAYER
	turf_flags = IS_SOLID
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	rad_insulation = RAD_MEDIUM_INSULATION
	pass_flags_self = PASSCLOSEDTURF
	var/use_splitvis = TRUE

/turf/closed/Initialize(mapload)
	. = ..()
	if(use_splitvis)
		// Micro-op to avoid needing to hash a bunch of nulls
		if(color)
			AddElement(/datum/element/split_visibility, icon, color)
		else
			AddElement(/datum/element/split_visibility, icon)
	else
		// We draw a copy to the wall plane so we can use it to mask byond darkness, that's all
		add_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", UNDER_WALL_LAYER, src, WALL_PLANE))


/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE
