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

	/// Weakrefs of all our hud viewers -> a weakref to the hud datum they last used
	var/list/datum/weakref/viewers_to_huds = list()
	/// The atom at the center of our display
	var/atom/center 
	/// Are we displaying JUST the center?
	/// Used to determine how much plane stack we need
	var/just_the_center = FALSE
	/// The upper bounds of our display view (width, height)
	var/list/display_bounds = list(0, 0)

/atom/movable/screen/map_view/Destroy()
	for(var/datum/weakref/client_ref in viewers_to_huds)
		var/client/our_client = client_ref.resolve()
		if(!our_client)
			var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
			var/datum/hud/viewing_hud = hud_ref?.resolve()
			if(!viewing_hud)
				continue
			var/datum/plane_master_group/popup/pop_planes = viewing_hud.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))
			qdel(pop_planes)
			continue
		hide_from(our_client.mob)

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
	// NOT apply to map popups.
	// We lazy load this because there's no point creating all these if none's gonna see em

	// Store this info in a client -> hud pattern, so ghosts closing the window nukes the right group
	var/datum/weakref/client_ref = WEAKREF(show_to.client)

	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	var/datum/hud/our_hud = hud_ref?.resolve()
	if(our_hud)
		return our_hud.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))

	// Generate a new plane group for this case
	var/datum/plane_master_group/popup/pop_planes = new(PLANE_GROUP_POPUP_WINDOW(src), assigned_map, src)
	viewers_to_huds[client_ref] = WEAKREF(show_to.hud_used)
	pop_planes.attach_to(show_to.hud_used)

	return pop_planes

/atom/movable/screen/map_view/proc/hide_from(mob/hide_from)
	hide_from?.canon_client.clear_map(assigned_map)
	var/client_ref = WEAKREF(hide_from?.canon_client)

	// Make sure we clear the *right* hud
	var/datum/weakref/hud_ref = viewers_to_huds[client_ref]
	viewers_to_huds -= client_ref
	var/datum/hud/clear_from = hud_ref?.resolve()
	if(!clear_from)
		return

	var/datum/plane_master_group/popup/pop_planes = clear_from.get_plane_group(PLANE_GROUP_POPUP_WINDOW(src))
	qdel(pop_planes)

/atom/movable/screen/map_view/proc/set_center(atom/center)
	if(src.center)
		UnregisterSignal(src.center, COMSIG_QDELETING)
	src.center = center
	if(center)
		RegisterSignal(center, COMSIG_QDELETING, PROC_REF(center_deleted))
	SEND_SIGNAL(src, COMSIG_MAP_CENTER_CHANGED, center)

/atom/movable/screen/map_view/proc/center_deleted(datum/source)
	SIGNAL_HANDLER
	set_center(null)

/atom/movable/screen/map_view/proc/set_display_bounds(width, height)
	display_bounds[1] = width
	display_bounds[2] = height
	SEND_SIGNAL(src, COMSIG_MAP_BOUNDS_CHANGED, display_bounds)

/atom/movable/screen/map_view/proc/enable_center_only()
	set_center_only(TRUE)

/atom/movable/screen/map_view/proc/disable_center_only()
	set_center_only(FALSE)
	
/atom/movable/screen/map_view/proc/set_center_only(just_the_center)
	src.just_the_center = just_the_center
	SEND_SIGNAL(src, COMSIG_MAP_RENDER_MODE_CHANGED, just_the_center)
