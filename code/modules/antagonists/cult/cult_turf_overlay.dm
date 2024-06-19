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
		linked.examine(user)

/obj/effect/cult_turf/singularity_act()
	return

/obj/effect/cult_turf/singularity_pull()
	return

/obj/effect/cult_turf/Destroy()
	if(linked)
		linked = null
	. = ..()
