/turf
	var/list/affecting_lights
	var/atom/movable/lighting_overlay/lighting_overlay

/turf/proc/reconsider_lights()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/reconsider_lights() called tick#: [world.time]")
	for(var/datum/light_source/L in affecting_lights)
		L.vis_update()

/turf/proc/lighting_clear_overlays()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/lighting_clear_overlays() called tick#: [world.time]")
//	testing("Clearing lighting overlays on \the [src]")
	if(lighting_overlay)
		returnToPool(lighting_overlay)

/turf/proc/lighting_build_overlays()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/lighting_build_overlays() called tick#: [world.time]")
	if(lighting_overlay)
		return

	var/atom/movable/lighting_overlay/O
	var/area/A = loc
	if(A.lighting_use_dynamic)
		O = getFromPool(/atom/movable/lighting_overlay, src)
		lighting_overlay = O
		all_lighting_overlays |= O

	//Make the light sources recalculate us so the lighting overlay updates INSTANTLY.
	for(var/datum/light_source/L in affecting_lights)
		L.calc_turf(src)

/turf/proc/get_lumcount(var/minlum = 0, var/maxlum = 1)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/get_lumcount() called tick#: [world.time]")
	if(!lighting_overlay) //We're not dynamic, whatever, return 50% lighting.
		return 0.5

	var/totallums = 0

	totallums = (lighting_overlay.lum_r + lighting_overlay.lum_b + lighting_overlay.lum_g) / 3

	totallums = (totallums - minlum) / (maxlum - minlum)

	return Clamp(totallums, 0, 1)

//Proc I made to dick around with update lumcount.
/turf/proc/update_lumcount(delta_r, delta_g, delta_b)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/update_lumcount() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/turf/proc/update_overlay() called tick#: [world.time]")
	lighting_overlay.update_overlay()
