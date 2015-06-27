/datum/controller/process/lighting/setup()
	name = "lighting"
	schedule_interval = LIGHTING_INTERVAL

	create_lighting_overlays()

/datum/controller/process/lighting/doWork()
	var/list/lighting_update_lights_old = lighting_update_lights.Copy() //We use a different list so any additions to the update lists during a delay from scheck() don't cause things to be cut from the list without being updated.
	lighting_update_lights = null
	lighting_update_lights = new

	for(var/datum/light_source/L in lighting_update_lights_old)
		if(L.needs_update)
			if(L.destroyed || L.check() || L.force_update)
				L.remove_lum()
				if(!L.destroyed)
					L.apply_lum()
			L.force_update = 0
			L.needs_update = 0

		scheck()

	var/list/lighting_update_overlays_old = lighting_update_overlays.Copy() //Same as above.
	lighting_update_overlays = null
	lighting_update_overlays = new

	for(var/atom/movable/lighting_overlay/O in lighting_update_overlays_old)
		if(O.needs_update)
			O.update_overlay()
			O.needs_update = 0

		scheck()
	lighting_update_lights_old = null
	lighting_update_overlays_old = null
