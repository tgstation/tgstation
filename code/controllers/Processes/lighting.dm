// Solves problems with lighting updates lagging shit
// Max constraints on number of updates per doWork():
#define MAX_LIGHT_UPDATES_PER_WORK		100
#define MAX_OVERLAY_UPDATES_PER_WORK	1000

/datum/controller/process/lighting
	schedule_interval = LIGHTING_INTERVAL

/datum/controller/process/lighting/setup()
	name = "lighting"

	create_lighting_overlays()

/datum/controller/process/lighting/doWork()
	// Counters
	var/light_updates	= 0
	var/overlay_updates	= 0

	var/list/lighting_update_lights_old = lighting_update_lights //We use a different list so any additions to the update lists during a delay from scheck() don't cause things to be cut from the list without being updated.
	lighting_update_lights = list()
	for(var/datum/light_source/L in lighting_update_lights_old)
		if(light_updates >= MAX_LIGHT_UPDATES_PER_WORK)
			lighting_update_lights += L
			continue // DON'T break, we're adding stuff back into the update queue.

		. = L.check()
		if(L.destroyed || . || L.force_update)
			L.remove_lum()
			if(!L.destroyed)
				L.apply_lum()

		else if(L.vis_update)	//We smartly update only tiles that became (in) visible to use.
			L.smart_vis_update()

		L.vis_update = 0
		L.force_update = 0
		L.needs_update = 0

		light_updates++

		scheck()

	var/list/lighting_update_overlays_old = lighting_update_overlays //Same as above.
	lighting_update_overlays = list()

	for(var/atom/movable/lighting_overlay/O in lighting_update_overlays_old)
		if(overlay_updates >= MAX_OVERLAY_UPDATES_PER_WORK)
			lighting_update_overlays += O
			continue // DON'T break, we're adding stuff back into the update queue.

		O.update_overlay()
		O.needs_update = 0
		overlay_updates++
		scheck()

	// TODO: Need debug pane for this.
//	to_chat(world, "LIT: [light_updates]:[overlay_updates]")


#undef MAX_LIGHT_UPDATES_PER_WORK
#undef MAX_OVERLAY_UPDATES_PER_WORK