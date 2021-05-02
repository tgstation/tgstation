GLOBAL_LIST_EMPTY(frill_objects)


/proc/get_frill_object(icon_path, junction, shadow = FALSE, alpha = 255, pixel_x = 0, pixel_y = 0, plane = FRILL_PLANE)
	. = GLOB.frill_objects["[icon_path]-[junction]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]"]
	if(.)
		return
	. = GLOB.frill_objects["[icon_path]-[junction]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]"] = new /atom/movable/visual/frill(null, icon_path, junction, shadow, alpha, pixel_x, pixel_y, plane)


/**
  * Attached to smoothing atoms. Adds a globally-cached object to their vis_contents and updates based on junction changes.
  ** ATTENTION: This element was supposed to be for atoms, but since only movables and turfs actually have vis_contents hacks have to be done.
  ** For now it treats all of its targets as turfs, but that will runtime if an invalid variable access happens.
  ** Yes, this is ugly. The alternative is making two different elements for the same purpose.
  */
/datum/element/frill
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/icon_path


/datum/element/frill/Attach(datum/target, icon_path)
	var/yep_its_a_turf = isturf(target)
	if(!yep_its_a_turf && !ismovable(target)) // Turfs and movables have vis_contents. Atoms don't. Pain.
		return ELEMENT_INCOMPATIBLE
	. = ..()
	src.icon_path = icon_path

	var/turf/turf_or_movable = target
	var/turf/operator_turf = yep_its_a_turf ? get_step(turf_or_movable, NORTH) : turf_or_movable
	operator_turf.vis_contents += get_frill_object(icon_path, turf_or_movable.smoothing_junction, TRUE, pixel_y = yep_its_a_turf ? 0 : 32)
	RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, .proc/on_junction_change)

/datum/element/frill/Detach(turf/target)
	if(isturf(target))
		target = get_step(target, NORTH)
	target.vis_contents -= get_frill_object(icon_path, target.smoothing_junction, TRUE)
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	return ..()


/datum/element/frill/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	var/turf/turf_or_movable = source
	var/turf/operator_turf = isturf(source) ? get_step(turf_or_movable, NORTH) : turf_or_movable
	operator_turf.vis_contents -= get_frill_object(icon_path, turf_or_movable.smoothing_junction, TRUE)
	operator_turf.vis_contents += get_frill_object(icon_path, new_junction, TRUE)


/atom/movable/visual/frill
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE
	layer = ABOVE_MOB_LAYER
	plane = FRILL_PLANE
	vis_flags = NONE


/atom/movable/visual/frill/Initialize(mapload, icon, junction, shadow, custom_alpha, custom_pixel_x, custom_pixel_y, custom_plane)
	. = ..()
	src.icon = icon
	icon_state = "frill-[junction]"
	if(shadow)
		var/mutable_appearance/shadow_overlay = mutable_appearance(icon, junction, 0, UNDER_FRILL_PLANE, 120)
		add_overlay(list(shadow_overlay))
	if(!isnull(custom_alpha))
		alpha = custom_alpha
	if(!isnull(custom_pixel_x))
		pixel_x = custom_pixel_x
	if(!isnull(custom_pixel_y))
		pixel_y = custom_pixel_y
	if(!isnull(custom_plane))
		plane = custom_plane
