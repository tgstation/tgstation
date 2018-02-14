//an "overlay" used by chumbiswork walls and floors to appear normal to mesons.
/obj/effect/chumbiswork/overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/atom/linked

/obj/effect/chumbiswork/overlay/examine(mob/user)
	if(linked)
		linked.examine(user)

/obj/effect/chumbiswork/overlay/ex_act()
	return FALSE

/obj/effect/chumbiswork/overlay/singularity_act()
	return
/obj/effect/chumbiswork/overlay/singularity_pull()
	return

/obj/effect/chumbiswork/overlay/singularity_pull(S, current_size)
	return

/obj/effect/chumbiswork/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/chumbiswork/overlay/wall
	name = "chumbiswork wall"
	icon = 'icons/turf/walls/chumbiswork_wall.dmi'
	icon_state = "chumbiswork_wall"
	canSmoothWith = list(/obj/effect/chumbiswork/overlay/wall, /obj/structure/falsewall/brass)
	smooth = SMOOTH_TRUE
	layer = CLOSED_TURF_LAYER

/obj/effect/chumbiswork/overlay/wall/Initialize()
	. = ..()
	queue_smooth_neighbors(src)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/queue_smooth, src), 1)

/obj/effect/chumbiswork/overlay/wall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/chumbiswork/overlay/floor
	icon = 'icons/turf/floors.dmi'
	icon_state = "chumbiswork_floor"
	layer = TURF_LAYER

/obj/effect/chumbiswork/overlay/floor/bloodcult //this is used by BLOOD CULT, it shouldn't use such a path...
	icon_state = "cult"