/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = LIGHTING_INTERVAL

	create_lighting_overlays()

/datum/controller/process/lighting/doWork()
	for(var/datum/light_source/L in lighting_update_lights)
		if(L.needs_update)
			if(L.destroyed)
				L.remove_lum()
			else if(L.check() || L.force_update)
				L.remove_lum()
				L.apply_lum()
				L.force_update = 0
			L.needs_update = 0

		scheck()

	lighting_update_lights.Cut()

	for(var/atom/movable/lighting_overlay/O in lighting_update_overlays)
		if(O.needs_update)
			O.update_overlay()
			O.needs_update = 0

		scheck()

	lighting_update_overlays.Cut()
