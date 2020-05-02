/turf/open/transparent
	baseturfs = /turf/open/transparent/openspace
	var/can_show_space = FALSE

/turf/open/transparent/Initialize() // handle plane and layer here so that they don't cover other obs/turfs in Dream Maker
	. = ..()
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER

	return INITIALIZE_HINT_LATELOAD

/turf/open/transparent/LateInitialize()
	update_multiz(TRUE, TRUE)

/turf/open/transparent/Destroy()
	vis_contents.len = 0
	return ..()

/turf/open/transparent/update_multiz(prune_on_fail = FALSE, init = FALSE)
	. = ..()
	var/turf/T = below()
	if(!T)
		vis_contents.len = 0
		if(can_show_space)
			var/mutable_appearance/underlay_appearance = mutable_appearance('icons/turf/space.dmi', icon_state = SPACE_ICON_STATE, layer = TURF_LAYER, plane = PLANE_SPACE)
			underlays += underlay_appearance
		else if(prune_on_fail)
			ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return FALSE
	if(init)
		vis_contents += T
	return TRUE

/turf/open/transparent/multiz_turf_del(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

/turf/open/transparent/multiz_turf_new(turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz()

/turf/open/transparent/glass
	name = "Glass floor"
	desc = "Dont jump on it, or do, I'm not your mom."
	icon = 'icons/turf/floors/glass.dmi'
	icon_state = "floor_glass"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/open/transparent/glass, /turf/open/transparent/glass/reinforced)
	can_show_space = TRUE

/turf/open/transparent/glass/reinforced
	name = "Reinforced glass floor"
	desc = "Do jump on it, it can take it."
	icon = 'icons/turf/floors/reinf_glass.dmi'
