GLOBAL_LIST_EMPTY(frill_objects)
GLOBAL_VAR_INIT(frill_shadow_object, new /atom/movable/visual/frill_shadow(null))

/**
  * Attached to smoothing atoms. Adds a globally-cached object to their vis_contents and updates based on junction changes.
  ** ATTENTION: This element was supposed to be for atoms, but since only movables and turfs actually have vis_contents hacks have to be done.
  ** For now it treats all of its targets as turfs, but that will runtime if an invalid variable access happens.
  ** Yes, this is ugly. The alternative is making two different elements for the same purpose.
  */
/datum/element/frill
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	var/icon_path


/datum/element/frill/Attach(datum/target, icon_path)
	if(!isturf(target) && !ismovable(target)) // Turfs and movables have vis_contents. Atoms don't. Pain.
		return ELEMENT_INCOMPATIBLE
	. = ..()
	src.icon_path = icon_path
	var/turf/turf_or_movable = target
	turf_or_movable.vis_contents += get_frill_object(icon_path, turf_or_movable.smoothing_junction)
	RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, .proc/on_junction_change)


/datum/element/frill/Detach(turf/target)
	target.vis_contents -= get_frill_object(icon_path, target.smoothing_junction)
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	return ..()


/datum/element/frill/proc/get_frill_object(icon_path, junction)
	. = GLOB.frill_objects["[icon_path]-[junction]"]
	if(.)
		return
	. = GLOB.frill_objects["[icon_path]-[junction]"] = new /atom/movable/visual/frill(null, icon_path, junction)


/datum/element/frill/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	var/turf/turf_or_movable = source
	turf_or_movable.vis_contents -= get_frill_object(icon_path, turf_or_movable.smoothing_junction)
	turf_or_movable.vis_contents += get_frill_object(icon_path, new_junction)


/atom/movable/visual/frill
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE
	layer = ABOVE_MOB_LAYER
	plane = FRILL_PLANE
	vis_flags = NONE
	pixel_y = 32


/atom/movable/visual/frill/Initialize(mapload, icon, junction)
	. = ..()
	src.icon = icon
	icon_state = "frill-[junction]"
	vis_contents += GLOB.frill_shadow_object


/atom/movable/visual/frill_shadow
	icon = 'icons/effects/frills/shadow.dmi'
	icon_state = "shadow"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE
	layer = ABOVE_MOB_LAYER
	plane = UNDER_FRILL_PLANE
	vis_flags = VIS_UNDERLAY
