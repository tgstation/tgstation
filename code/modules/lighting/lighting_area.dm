/area
	luminosity           = TRUE
	var/dynamic_lighting = DYNAMIC_LIGHTING_ENABLED

/area/proc/set_dynamic_lighting(var/new_dynamic_lighting = DYNAMIC_LIGHTING_ENABLED)
	if (new_dynamic_lighting == dynamic_lighting)
		return FALSE

	dynamic_lighting = new_dynamic_lighting

	if (IS_DYNAMIC_LIGHTING(src))
		for (var/turf/T in area_contents(src))
			if (IS_DYNAMIC_LIGHTING(T))
				T.lighting_build_overlay()

	else
		for (var/turf/T in area_contents(src))
			if (T.lighting_overlay)
				T.lighting_clear_overlay()

	return TRUE
