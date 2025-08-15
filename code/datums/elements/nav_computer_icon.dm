/**
 * element for atoms that have helper icons overlayed on their position in the shuttle navigation computer, such as airlocks
 */
/datum/element/nav_computer_icon
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/use_icon
	var/use_icon_state
	var/only_show_on_shuttle_edge

/datum/element/nav_computer_icon/Attach(datum/target, use_icon, use_icon_state, only_show_on_shuttle_edge)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.use_icon = use_icon
	src.use_icon_state = use_icon_state
	src.only_show_on_shuttle_edge = only_show_on_shuttle_edge

	RegisterSignal(target, COMSIG_SHUTTLE_NAV_COMPUTER_IMAGE_REQUESTED, PROC_REF(provide_image))

/datum/element/nav_computer_icon/proc/provide_image(datum/source, list/images_out)
	SIGNAL_HANDLER
	var/obj/source_obj = source
	var/turf/source_turf = get_turf(source_obj)
	if(!source_turf)
		return
	if(only_show_on_shuttle_edge)
		var/isOnEdge = FALSE
		for(var/direction in GLOB.cardinals)
			var/turf/turf = get_step(source_obj, direction)
			if(!istype(turf?.loc, /area/shuttle))
				isOnEdge = TRUE
				break
		if(!isOnEdge)
			return

	var/image/the_image = image(use_icon, source_turf, use_icon_state)
	the_image.dir = source_obj.dir
	images_out += the_image

/datum/element/nav_computer_icon/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_SHUTTLE_NAV_COMPUTER_IMAGE_REQUESTED)
