/datum/element/turf_transparency
	var/show_below = FALSE

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_transparency/Attach(datum/target, show_below)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	src.show_below = show_below

	our_turf.plane = OPENSPACE_PLANE
	our_turf.layer = OPENSPACE_LAYER

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, .proc/on_multiz_turf_del)
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_turf_new)
	RegisterSignal(target, COMSIG_SIGNAL_IS_TRANSPARENT, .proc/transparency_bool)

	update_multiz(our_turf, TRUE, TRUE)

/datum/element/turf_transparency/Detach(datum/source, force)
	. = ..()
	var/turf/our_turf = source
	our_turf.vis_contents.len = 0

///Updates the viscontents or underlays below this tile.
/datum/element/turf_transparency/proc/update_multiz(turf/our_turf, prune_on_fail = FALSE, init = FALSE)
	var/turf/T = our_turf.below()
	if(!T)
		our_turf.vis_contents.len = 0
		if(!show_bottom_level(T) && prune_on_fail) //If we cant show whats below, and we prune on fail, change the turf to plating as a fallback
			our_turf.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return FALSE
	if(init)
		our_turf.vis_contents += T
	return TRUE

///Simply returns a bool, shitty work-around to allow objects to check if they are transparent.
/datum/element/turf_transparency/proc/transparency_bool()
	return COMSIG_TURF_TRANSPARENCY_TRUE

/datum/element/turf_transparency/proc/on_multiz_turf_del(turf/our_turf, turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz(our_turf)

/datum/element/turf_transparency/proc/on_multiz_turf_new(turf/our_turf, turf/T, dir)
	if(dir != DOWN)
		return
	update_multiz(our_turf)

///Called when there is no real turf below this turf
/datum/element/turf_transparency/proc/show_bottom_level(turf/our_turf)
	if(!show_below)
		return FALSE
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER, plane = PLANE_SPACE)
	our_turf.underlays += underlay_appearance
	return TRUE
