/**
 * A screen object, which acts as a container for turfs and other things
 * you want to show on the map, which you usually attach to "vis_contents".
 * Additionally manages the plane masters required to display said container contents
 */
INITIALIZE_IMMEDIATE(/atom/movable/screen/map_view)
/atom/movable/screen/map_view
	name = "screen"
	// Map view has to be on the lowest plane to enable proper lighting
	layer = GAME_PLANE
	plane = GAME_PLANE
	del_on_map_removal = FALSE

	// Weakrefs of all our hud viewers -> their active plane group
	var/list/datum/weakref/viewers_to_planes = list()

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/ref in viewers_to_planes)
		var/datum/hud/viewer = ref.resolve()
		if(!viewer)
			continue
		hide_from(viewer.mymob)

	return ..()

/atom/movable/screen/map_view/proc/generate_view(map_key)
	// Map keys have to start and end with an A-Z character,
	// and definitely NOT with a square bracket or even a number.
	// I wasted 6 hours on this. :agony:
	// -- Stylemistake
	assigned_map = map_key
	set_position(1, 1)

/atom/movable/screen/map_view/proc/display_to(mob/show_to)
	show_to.client.register_map_obj(src)
	// We need to add planesmasters to the popup, otherwise
	// blending fucks up massively. Any planesmaster on the main screen does
	// NOT apply to map popups. If there's ever a way to make planesmasters
	// omnipresent, then this wouldn't be needed.

	// We lazy load this because there's no point creating all these if none's gonna see em
	var/datum/weakref/hud_ref = WEAKREF(show_to.hud_used)
	var/datum/plane_master_group/popup/pop_planes = viewers_to_planes[hud_ref]
	if(!pop_planes)
		pop_planes = new(PLANE_GROUP_POPUP_WINDOW(src), assigned_map)
		viewers_to_planes[hud_ref] = pop_planes
		RegisterSignal(pop_planes, COMSIG_PARENT_QDELETING, .proc/clear_pop)

	pop_planes.attach_to(show_to.hud_used)
	return pop_planes

/atom/movable/screen/map_view/proc/hide_from(mob/hide_from)
	hide_from.client.clear_map(assigned_map)
	var/datum/plane_master_group/popup/pop_planes = viewers_to_planes[WEAKREF(hide_from.hud_used)]
	// Rely on the signal to clean up our refs and all
	qdel(pop_planes)

/atom/movable/screen/map_view/proc/clear_pop(datum/plane_master_group/source)
	SIGNAL_HANDLER
	viewers_to_planes -= WEAKREF(source.our_hud)
