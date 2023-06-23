GLOBAL_LIST_INIT(oshan_launch_points, list())

/obj/effect/oshan_launch_point
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0

	icon = 'monkestation/icons/effects/effects.dmi'
	icon_state = "launch_point"
	var/map_edge_direction = SOUTH

/obj/effect/oshan_launch_point/player
	name = "player launch point"

/obj/effect/oshan_launch_point/player/Initialize(mapload)
	. = ..()
	GLOB.oshan_launch_points += src

/obj/effect/oshan_launch_point/player/Destroy(force)
	. = ..()
	GLOB.oshan_launch_points -= src

/obj/structure/closet/stasis_pod
	name = "human capsule missile"
	desc = "The cheapest way to get people down to the bottom of the ocean"

	icon = 'goon/icons/obj/large/32x64.dmi'
	icon_state = "arrival_missile"
	bound_width = 32
	bound_height = 64

	movement_type = PHASING

	welded = TRUE
	locked = TRUE

/obj/structure/closet/stasis_pod/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(start_deleting)), 3 SECONDS)

/obj/structure/closet/stasis_pod/proc/start_deleting()
	open(null, TRUE)
	qdel(src)
