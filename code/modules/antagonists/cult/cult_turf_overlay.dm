//an "overlay" used by clockwork walls and floors to appear normal to mesons.
/obj/effect/cult_turf/overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/atom/linked

/obj/effect/cult_turf/overlay/examine(mob/user)
	if(linked)
		linked.examine(user)

/obj/effect/cult_turf/overlay/singularity_act()
	return

/obj/effect/cult_turf/overlay/singularity_pull()
	return

/obj/effect/cult_turf/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/cult_turf/overlay/floor
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"
	layer = CULT_OVERLAY_LAYER

/obj/effect/cult_turf/overlay/floor/bloodcult
	icon_state = "cult"
