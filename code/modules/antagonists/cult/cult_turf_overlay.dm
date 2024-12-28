//an "overlay" used by cult walls and floors to appear normal to mesons.
/obj/effect/cult_turf
	icon = 'icons/turf/floors.dmi'
	icon_state = "cult"
	plane = FLOOR_PLANE
	layer = CULT_OVERLAY_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/atom/linked

/obj/effect/cult_turf/examine(mob/user)
	if(linked)
		return linked.examine(user)
	return list()

/obj/effect/cult_turf/singularity_act()
	return

/obj/effect/cult_turf/singularity_pull(atom/singularity, current_size)
	return

/obj/effect/cult_turf/Destroy()
	if(linked)
		linked = null
	. = ..()
