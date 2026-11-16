/turf/closed
	layer = CLOSED_TURF_LAYER
	plane = WALL_PLANE
	abstract_type = /turf/closed
	turf_flags = IS_SOLID
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	rad_insulation = RAD_MEDIUM_INSULATION
	pass_flags_self = PASSCLOSEDTURF
	tacmap_color = TACMAP_BLACK

/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/examine_descriptor(mob/user)
	return "wall"

/**
 * Some turfs (mineral) are big, so they need to be on the game plane at a high layer
 * But they're also turfs, so we need to cut them out from the light mask plane
 * So we draw them as if they were on the game plane, and then overlay a copy onto
 * The wall plane (so emissives/light masks behave)
 * I am so sorry
 */
/turf/closed/proc/add_large_wall_overlay(wall_icon, wall_state)
	var/static/list/mutable_appearance/wall_overlays = list()
	var/mutable_appearance/wall_overlay = wall_overlays["[wall_icon]-[wall_state]"]
	if (!wall_overlay)
		wall_overlay = mutable_appearance('icons/turf/mining.dmi', wall_state, appearance_flags = RESET_TRANSFORM)
		wall_overlays["[wall_icon]-[wall_state]"] = wall_overlay
	wall_overlay.plane = MUTATE_PLANE(WALL_PLANE, src)
	overlays += wall_overlay
