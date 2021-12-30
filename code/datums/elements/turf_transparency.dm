
/datum/element/turf_z_transparency
	element_flags = ELEMENT_DETACH
	var/is_openspace = FALSE

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, is_openspace = FALSE)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	our_turf.layer = OPENSPACE_LAYER
	if(is_openspace)
		our_turf.plane = OPENSPACE_PLANE

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, .proc/on_multiz_turf_del)
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_turf_new)

	ADD_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

	var/turf/below_turf = our_turf.below()
	if(below_turf)
		our_turf.vis_contents += below_turf
	update_multi_z(our_turf)

/datum/element/turf_z_transparency/Detach(datum/source)
	. = ..()
	var/turf/our_turf = source
	our_turf.vis_contents.len = 0
	UnregisterSignal(our_turf, list(COMSIG_TURF_MULTIZ_NEW, COMSIG_TURF_MULTIZ_DEL))
	REMOVE_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

///Updates the viscontents or underlays below this tile.
/datum/element/turf_z_transparency/proc/update_multi_z(turf/our_turf)
	var/turf/below_turf = our_turf.below()
	if(!below_turf)
		our_turf.vis_contents.len = 0
		add_baseturf_underlay(our_turf)

	if(isclosedturf(our_turf)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += plating_underlay
	return TRUE

/datum/element/turf_z_transparency/proc/on_multiz_turf_del(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

/datum/element/turf_z_transparency/proc/on_multiz_turf_new(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

///Called when there is no real turf below this turf
/datum/element/turf_z_transparency/proc/add_baseturf_underlay(turf/our_turf)
	if(is_openspace) // we don't ever want our bottom turf to be openspace
		our_turf.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, plane = PLANE_SPACE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	our_turf.underlays += underlay_appearance
