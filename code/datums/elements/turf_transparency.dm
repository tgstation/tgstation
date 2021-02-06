#define MULTIZ_SHIFT 8

/turf
	var/atom/movable/visual/below/below = null /// used by show_below_turf

///Show the turf on the z-level below this one.
/turf/proc/show_below_turf(show_bottom_level = TRUE)
	below = new(null, src, show_bottom_level)
	vis_contents += below

///Hide the turf on the z-level below this one.
/turf/proc/hide_below_turf()
	vis_contents -= below
	qdel(below)

///Appearance of a below turf
/atom/movable/visual/below
	pixel_y = -MULTIZ_SHIFT
	vis_flags = VIS_INHERIT_ID
	plane = OPENSPACE_PLANE
	layer = OPENSPACE_LAYER
	var/show_bottom_level
	var/turf/source

/atom/movable/visual/below/Initialize(mapload, turf/our_turf, show_bottom_level)
	. = ..()
	RegisterSignal(our_turf, COMSIG_TURF_MULTIZ_DEL, .proc/update_icon)
	RegisterSignal(our_turf, COMSIG_TURF_MULTIZ_NEW, .proc/update_icon)
	src.show_bottom_level = show_bottom_level
	source = our_turf
	update_icon()

/atom/movable/visual/below/Destroy()
	. = ..()
	UnregisterSignal(source, COMSIG_TURF_MULTIZ_DEL)
	UnregisterSignal(source, COMSIG_TURF_MULTIZ_NEW)
	source = null
	vis_contents.len = 0

/atom/movable/visual/below/update_icon()
	. = ..()

	var/turf/below = source.below()

	vis_contents.len = 0

	if(below)
		vis_contents += below
	else if(show_bottom_level)
		var/turf/path = SSmapping.level_trait(source.z, ZTRAIT_BASETURF) || /turf/open/space
		if(!ispath(path))
			path = text2path(path)
			if(!ispath(path))
				warning("Z-level [source.z] has invalid baseturf '[SSmapping.level_trait(source.z, ZTRAIT_BASETURF)]'")
				path = /turf/open/space
		var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, plane = PLANE_SPACE)
		underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
		underlays += underlay_appearance

	if(isclosedturf(source)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		underlays += girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay = RESET_ALPHA | RESET_COLOR
		underlays += plating_underlay

/datum/element/turf_z_transparency
	var/show_bottom_level

/datum/element/turf_z_transparency/Attach(datum/target, show_bottom_level = TRUE)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target
	if(!show_bottom_level && !our_turf.below())
		our_turf.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return

	src.show_bottom_level = show_bottom_level

	our_turf.show_below_turf(show_bottom_level)
	ADD_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, TURF_TRAIT)

	change_north(null, get_step(our_turf, NORTH))

/datum/element/turf_z_transparency/Detach(datum/source, force)
	. = ..()

	var/turf/our_turf = source
	REMOVE_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, TURF_TRAIT)
	our_turf.hide_below_turf()

	var/turf/north = get_step(our_turf, NORTH)
	if(north && !istransparentturf(north))
		north.hide_below_turf()

/datum/element/turf_z_transparency/proc/change_north_before(turf/source)
	SIGNAL_HANDLER

	if(source && !istransparentturf(source))
		source.hide_below_turf()


/datum/element/turf_z_transparency/proc/change_north(turf/north)
	SIGNAL_HANDLER

	if(!north)
		return
	if(!istransparentturf(north))
		north.show_below_turf()
	RegisterSignal(north, COMSIG_TURF_CHANGE, .proc/change_north_before)
	RegisterSignal(north, COMSIG_TURF_CHANGED, .proc/change_north)
