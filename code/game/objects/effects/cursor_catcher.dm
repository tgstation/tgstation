/// An effect which tracks the cursor's location on the screen
/atom/movable/screen/fullscreen/cursor_catcher
	icon_state = "fullscreen_blocker" // Fullscreen semi transparent icon
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	default_click = TRUE
	/// The mob whose cursor we are tracking.
	var/mob/owner
	/// Client view size of the scoping mob.
	var/list/view_list
	/// Pixel x relative to the hovered tile we send to the scope component.
	var/given_x
	/// Pixel y relative to the hovered tile we send to the scope component.
	var/given_y
	/// The turf we send to the scope component.
	var/turf/given_turf
	/// Mouse parameters, for calculation.
	var/mouse_params

/// Links this up with a mob
/atom/movable/screen/fullscreen/cursor_catcher/proc/assign_to_mob(mob/owner)
	src.owner = owner
	view_list = getviewsize(owner.client.view)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(owner, COMSIG_VIEWDATA_UPDATE, PROC_REF(on_viewdata_update))
	calculate_params()

/// Update when the mob we're assigned to has moved
/atom/movable/screen/fullscreen/cursor_catcher/proc/on_move(atom/source, atom/oldloc, dir, forced)
	SIGNAL_HANDLER

	if(!given_turf)
		return
	var/x_offset = source.loc.x - oldloc.x
	var/y_offset = source.loc.y - oldloc.y
	given_turf = locate(given_turf.x+x_offset, given_turf.y+y_offset, given_turf.z)

/// Update when our screen size changes
/atom/movable/screen/fullscreen/cursor_catcher/proc/on_viewdata_update(datum/source, view)
	SIGNAL_HANDLER

	view_list = getviewsize(view)

/atom/movable/screen/fullscreen/cursor_catcher/MouseEntered(location, control, params)
	. = ..()
	MouseMove(location, control, params)
	if(usr == owner)
		calculate_params()

/atom/movable/screen/fullscreen/cursor_catcher/MouseMove(location, control, params)
	if(usr != owner)
		return
	mouse_params = params

/atom/movable/screen/fullscreen/cursor_catcher/proc/calculate_params()
	var/list/modifiers = params2list(mouse_params)
	var/icon_x = text2num(LAZYACCESS(modifiers, VIS_X))
	if(isnull(icon_x))
		icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, VIS_Y))
	if(isnull(icon_y))
		icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	var/our_x = round(icon_x / world.icon_size)
	var/our_y = round(icon_y / world.icon_size)
	given_turf = locate(owner.x + our_x - round(view_list[1]/2), owner.y + our_y - round(view_list[2]/2), owner.z)
	given_x = round(icon_x - world.icon_size * our_x, 1)
	given_y = round(icon_y - world.icon_size * our_y, 1)
