/turf
	var/list/affecting_lights
	var/atom/movable/lighting_overlay/lighting_overlay

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
//	testing("Clearing lighting overlays on \the [src]")
	if(lighting_overlay)
		qdel(lighting_overlay)

/turf/proc/lighting_build_overlays()
	if(lighting_overlay)
		return

	var/state = "light1"
	var/area/A = loc
	if(A.lighting_use_dynamic)
		var/atom/movable/lighting_overlay/O = new(src)
		O.icon_state = state
		lighting_overlay = O
		all_lighting_overlays |= O

/turf/proc/lighting_refresh_overlays()
	lighting_clear_overlays()
	lighting_build_overlays()

/turf/proc/lighting_fix_overlays()	 //Purge all overlays and rebuild them
	lighting_clear_overlays()
	for(var/atom/movable/lighting_overlay/L in src.contents)
		qdel(L)
	lighting_build_overlays()
	return

turf/proc/lighting_test_overlays()
	var/count
	for(var/atom/movable/lighting_overlay/L in src.contents)
		count++
	if (count > 1)
		return 1
	return 0


/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!dynamic_lighting) //We're not dynamic, whatever, return 50% lighting.
		return 0.5


	var/totallums = 0

	if(!lighting_overlay) //U WOT
		return

	totallums = (lighting_overlay.lum_r + lighting_overlay.lum_b + lighting_overlay.lum_g) / 3


	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	lighting_overlay.update_lumcount(delta_r, delta_g, delta_b)



/turf/proc/set_lumcount(red, green, blue)
	lighting_overlay.set_lumcount(red, green, blue)


//Used for shuttles
/turf/proc/update_overlay()
	if(lighting_overlay)
		lighting_overlay.update_overlay()


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