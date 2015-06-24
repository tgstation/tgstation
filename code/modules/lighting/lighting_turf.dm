/turf
	var/list/affecting_lights
	var/atom/movable/lighting_overlay/lighting_overlay

/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.force_update()

/turf/proc/lighting_clear_overlays()
//	testing("Clearing lighting overlays on \the [src]")
	if(lighting_overlay)
		returnToPool(lighting_overlay)

/turf/proc/lighting_build_overlays()
	if(lighting_overlay)
		return

	var/area/A = loc
	if(A.lighting_use_dynamic)
		var/atom/movable/lighting_overlay/O = new(src)
		lighting_overlay = O
		all_lighting_overlays |= O

/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!lighting_overlay) //We're not dynamic, whatever, return 50% lighting.
		return 0.5

	var/totallums = 0

	totallums = (lighting_overlay.lum_r + lighting_overlay.lum_b + lighting_overlay.lum_g) / 3

	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount.
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	if(lighting_overlay)
		lighting_overlay.update_lumcount(delta_r, delta_g, delta_b)

/turf/Entered(atom/movable/Obj, atom/OldLoc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()

/turf/Exited(atom/movable/Obj, atom/newloc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()

//Testing proc like update_lumcount.
/turf/proc/update_overlay()
	lighting_overlay.update_overlay()
