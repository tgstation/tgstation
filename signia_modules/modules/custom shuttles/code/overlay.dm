/*
 * Manages the overlays for the shuttle creator drone.
*/

/datum/shuttle_creator_overlay_holder
	var/client/holder
	var/list/images = list()
	var/list/turfs = list()

/datum/shuttle_creator_overlay_holder/proc/add_client(client/C)
	holder = C
	holder.images += images

/datum/shuttle_creator_overlay_holder/proc/remove_client()
	holder.images -= images
	holder = null

/datum/shuttle_creator_overlay_holder/proc/clear_highlights()
	if(holder)
		holder.images -= images
	images.Cut()
	turfs.Cut()

/datum/shuttle_creator_overlay_holder/proc/create_hightlight(turf/T)
	if(T in turfs)
		return
	var/image/I = image('icons/turf/overlays.dmi', T, "greenOverlay")
	I.plane = ABOVE_LIGHTING_PLANE
	images += I
	holder.images += I
	turfs += T

/datum/shuttle_creator_overlay_holder/proc/remove_hightlight(turf/T)
	if(!(T in turfs))
		return
	turfs -= T
	holder.images -= images
	for(var/image/I in images)
		if(get_turf(I) != T)
			continue
		images -= I
	holder.images += images

/datum/shuttle_creator_overlay_holder/proc/highlight_area(list/turfs)
	for(var/turf/T in turfs)
		highlight_turf(T)

/datum/shuttle_creator_overlay_holder/proc/highlight_turf(turf/T)
	create_hightlight(T)

/datum/shuttle_creator_overlay_holder/proc/unhighlight_turf(turf/T)
	remove_hightlight(T)
