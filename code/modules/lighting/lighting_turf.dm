/turf
	var/list/affecting_lights // List of light sources affecting this turf.
	var/atom/movable/lighting_overlay/lighting_overlay // Our lighting overlay.

// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	for(var/datum/light_source/L in affecting_lights)
		L.vis_update()

// Removes the overlay (the proc name is plural from a long forgotten past).
/turf/proc/lighting_clear_overlays()
//	testing("Clearing lighting overlays on \the [src]")
	if(lighting_overlay)
		returnToPool(lighting_overlay)

// Builds a lighting overlay for us, but only if our area is dynamic.
/turf/proc/lighting_build_overlays()
	if(lighting_overlay)
		return

	var/atom/movable/lighting_overlay/O
	var/area/A = loc
	if(A.lighting_use_dynamic)
		O = getFromPool(/atom/movable/lighting_overlay, src)
		lighting_overlay = O
		all_lighting_overlays |= O

	// Make the light sources recalculate us so the lighting overlay updates INSTANTLY.
	for(var/datum/light_source/L in affecting_lights)
		L.calc_turf(src)

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	if(!lighting_overlay) //We're not dynamic, whatever, return 50% lighting.
		return 0.5

	var/totallums = 0
	if(lighting_overlay.lum_r) totallums += lighting_overlay.lum_r
	if(lighting_overlay.lum_b) totallums += lighting_overlay.lum_b
	if(lighting_overlay.lum_g) totallums += lighting_overlay.lum_g
	if(totallums)
		totallums /= 3 // Get the average between the 3 spectrums
	else
		return 0
	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

// If an opaque movable atom moves around we need to potentially update visibility.
/turf/Entered(var/atom/movable/Obj, var/atom/OldLoc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()

/turf/Exited(var/atom/movable/Obj, var/atom/newloc)
	. = ..()

	if(Obj && Obj.opacity)
		reconsider_lights()
