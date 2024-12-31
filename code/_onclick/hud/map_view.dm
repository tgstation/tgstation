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

	// Weakrefs of all our hud viewers -> a weakref to the hud datum they last used
	var/list/datum/weakref/viewers_to_huds = list()

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/client_ref in viewers_to_huds)
		hide_from_client(client_ref.resolve())

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

	// Store this info in a client -> hud pattern, so ghosts closing the window nukes the right group
	var/datum/weakref/client_ref = WEAKREF(show_to.client)

	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	var/datum/hud/our_hud = hud_ref?.resolve()
	if(our_hud)
		return our_hud.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))

	// Generate a new plane group for this case
	var/datum/plane_master_group/popup/pop_planes = new(PLANE_GROUP_POPUP_WINDOW(src), assigned_map)
	viewers_to_huds[client_ref] = WEAKREF(show_to.hud_used)
	pop_planes.attach_to(show_to.hud_used)

	return pop_planes

/atom/movable/screen/map_view/proc/hide_from(mob/hide_from)
	hide_from_client(hide_from?.canon_client)

/atom/movable/screen/map_view/proc/hide_from_client(client/hide_from)
	if(!hide_from)
		return
	hide_from.clear_map(assigned_map)

	var/datum/weakref/client_ref = WEAKREF(hide_from)
	// Make sure we clear the *right* hud
	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	viewers_to_huds -= client_ref

	var/datum/hud/clear_from = hud_ref?.resolve()
	if(!clear_from)
		return

	var/datum/plane_master_group/popup/pop_planes = clear_from.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))
	qdel(pop_planes)
