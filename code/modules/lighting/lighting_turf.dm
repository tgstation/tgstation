/turf
	var/list/affecting_lights
	#if LIGHTING_RESOLUTION == 1
	var/atom/movable/lighting_overlay/lighting_overlay
	#else
	var/list/lighting_overlays[LIGHTING_RESOLUTION ** 2]
	#endif

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
//	testing("Clearing lighting overlays on \the [src]")
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
		qdel(lighting_overlay)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		qdel(L)
	#endif

/turf/proc/lighting_build_overlays()
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
	#else
	if(lighting_overlays.len)
	#endif
		return

	var/state = "light[LIGHTING_RESOLUTION]"
	var/area/A = loc
	if(A.lighting_use_dynamic)
		#if LIGHTING_RESOLUTION == 1
		var/atom/movable/lighting_overlay/O = new(src)
		O.icon_state = state
		lighting_overlay = O
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

/turf/proc/lighting_refresh_overlays()
	lighting_clear_overlays()
	lighting_build_overlays()

/turf/proc/lighting_fix_overlays()	 //Purge all overlays and rebuild them
	lighting_clear_overlays()
	for(var/atom/movable/lighting_overlay/L in src)
		qdel(L)
	lighting_build_overlays()
	return

turf/proc/lighting_test_overlays()
	var/count
	for(var/atom/movable/lighting_overlay/L in src)
		count++
	if (count > 1)
		return 1
	return 0


/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!dynamic_lighting) //We're not dynamic, whatever, return 50% lighting.
		return 0.5


	var/totallums = 0
	#if LIGHTING_RESOLUTION == 1

	if(!lighting_overlay) //U WOT
		return

	totallums = (lighting_overlay.lum_r + lighting_overlay.lum_b + lighting_overlay.lum_g) / 3

	#else

	if(!lighting_overlays.len) //Ya wot.
		return

	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		if(!L) //u fukken wot m8
			return
		totallums += (L.lum_r + L.lum_g + L.lum_b) / 3

	totallums /= lighting_overlays.len //Get the average, used for higher resolutions of lighting.

	#endif

	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	#if LIGHTING_RESOLUTION == 1
	lighting_overlay.update_lumcount(delta_r, delta_g, delta_b)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.update_lumcount(delta_r, delta_g, delta_b)
	#endif


/turf/proc/set_lumcount(red, green, blue)
	#if LIGHTING_RESOLUTION == 1
	lighting_overlay.set_lumcount(red, green, blue)
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.set_lumcount(red, green, blue)
	#endif

//Used for shuttles
/turf/proc/update_overlay()
	#if LIGHTING_RESOLUTION == 1
	if(lighting_overlay)
		lighting_overlay.update_overlay()
	#else
	for(var/atom/movable/lighting_overlay/L in lighting_overlays)
		L.update_overlay()
	#endif

/turf/Entered(atom/movable/Obj, atom/OldLoc)
	if(Obj && Obj.opacity)
		reconsider_lights()
	if(Obj && OldLoc != src)
		Obj.update_all_lights()
	..()

/turf/Exited(atom/movable/Obj, atom/newloc)
	..()
	if(Obj && Obj.opacity)
		reconsider_lights()