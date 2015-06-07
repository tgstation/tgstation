/turf
	var/list/affecting_lights
	var/list/lighting_overlays[0]

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		lighting_overlays -= L
		all_lighting_overlays -= L
		lighting_update_overlays -= L //Incase the overlay gets deleted after being queued up for updating.
		L.needs_update = 0
		L.loc = null

/turf/proc/lighting_build_overlays()
	if(lighting_overlays.len)//The lighting_overlays list exists, which means there should have already been built overlays.
		return

	var/state = "light[LIGHTING_RESOLUTION]"
	var/area/A = loc
	if(A.lighting_use_dynamic)
		#if LIGHTING_RESOLUTION == 1
		var/atom/movable/lighting_overlay/O = new(src)
		O.icon_state = state
		lighting_overlays |= O
		all_lighting_overlays |= O
		#else
		for(var/i = 0; i < LIGHTING_RESOLUTION; i++)
			for(var/j = 0; j < LIGHTING_RESOLUTION; j++)
				var/atom/movable/lighting_overlay/O = new(src)
				O.pixel_x = i * (32 / LIGHTING_RESOLUTION)
				O.pixel_y = j * (32 / LIGHTING_RESOLUTION)
				O.xoffset = (((2*i + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.yoffset = (((2*j + 1) / (LIGHTING_RESOLUTION * 2)) - 0.5)
				O.icon_state = state
				lighting_overlays |= O
				all_lighting_overlays |= O
		#endif

/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!dynamic_lighting) //We're not dynamic, whatever, return 50% lighting.
		return 0.5

	if(!lighting_overlays.len) //Ya wot.
		return

	var/totallums = 0
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		totallums += (L.lum_r + L.lum_g + L.lum_b) / 3

	totallums /= lighting_overlays.len //Get the average, used for higher resolutions of lighting.

	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.update_lumcount(delta_r, delta_g, delta_b)

/turf/Entered(atom/movable/Obj, atom/OldLoc)
	. = ..()

	if(Obj.opacity)
		reconsider_lights()

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if(Obj.opacity)
		reconsider_lights()