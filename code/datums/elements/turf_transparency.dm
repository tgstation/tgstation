/datum/element/turf_z_transparency
	var/show_bottom_level = FALSE

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, show_bottom_level = TRUE)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	src.show_bottom_level = show_bottom_level

	our_turf.plane = OPENSPACE_PLANE
	our_turf.layer = OPENSPACE_LAYER

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, .proc/on_multiz_turf_del)
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_turf_new)

	ADD_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, TURF_TRAIT)


	update_multiz(our_turf, TRUE, TRUE)

/datum/element/turf_z_transparency/Detach(datum/source, force)
	. = ..()
	var/turf/our_turf = source
	our_turf.vis_contents.len = 0
	REMOVE_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, TURF_TRAIT)

///Updates the viscontents or underlays below this tile.
/datum/element/turf_z_transparency/proc/update_multiz(turf/our_turf, prune_on_fail = FALSE, init = FALSE)
	var/turf/below_turf = our_turf.below()
	if(!below_turf)
		our_turf.vis_contents.len = 0
		if(!show_bottom_level(our_turf) && prune_on_fail) //If we cant show whats below, and we prune on fail, change the turf to plating as a fallback
			our_turf.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return FALSE
	if(init)
		our_turf.vis_contents += below_turf
	if(isclosedturf(our_turf)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += plating_underlay
	return TRUE

/datum/element/turf_z_transparency/proc/on_multiz_turf_del(turf/our_turf, turf/T, dir)
	SIGNAL_HANDLER 
	if(dir != DOWN)
		return
	update_multiz(our_turf)

/datum/element/turf_z_transparency/proc/on_multiz_turf_new(turf/our_turf, turf/T, dir)
	SIGNAL_HANDLER 
	if(dir != DOWN)
		return
	update_multiz(our_turf)

///Called when there is no real turf below this turf
/datum/element/turf_z_transparency/proc/show_bottom_level(turf/our_turf)
	if(!show_bottom_level)
		return FALSE
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, plane = PLANE_SPACE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	our_turf.underlays += underlay_appearance
	return TRUE
