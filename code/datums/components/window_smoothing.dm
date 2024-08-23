// Yello
// This component mangages drawing windows, and their smoothing
// It mostly exists because of how windows need to "sorta" smooth with walls
// And the extra rules around that and frills
// Love you <3

/mutable_appearance/window_vis

/mutable_appearance/window_vis/New()
	. = ..()
	// Need to do this here because it's overriden by the parent call
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

GLOBAL_LIST_EMPTY(window_appearances)

/proc/get_window_appearance(z_offset, icon_path, junction, side, alt = FALSE, pixel_y = 0, plane = GAME_PLANE)
	var/key = "[icon_path]-[junction]-[side]-[alt]-[pixel_y]-[plane]-[z_offset]"
	var/mutable_appearance/split_vis/vis = GLOB.window_appearances[key]
	if(vis)
		return vis

	vis = new /mutable_appearance/split_vis()
	vis.icon = icon_path
	var/state = junction ? "[junction]-[side]" : "0-[side]"
	if(alt)
		state = "alt-[state]"
	vis.icon_state = state
	vis.pixel_y = pixel_y
	SET_PLANE_W_SCALAR(vis, plane, z_offset)

	GLOB.window_appearances[key] = vis
	return vis

/datum/component/window_smoothing
	var/icon_path
	var/list/mutable_appearance/our_appearances = list()
	var/mutable_appearance/appearance_above
	var/turf/paired_turf
	/// A type of turf to ignore when doing our closed check
	/// Useful for cases where WE are a turf! *gasp of shock/fear*
	var/turf/ignored_turf

/datum/component/window_smoothing/Initialize(ignored_turf = null)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/parent_atom = parent
	if(!(parent_atom.smoothing_flags & (SMOOTH_BITMASK|SMOOTH_BITMASK_CARDINALS)))
		stack_trace("We tried to splitvis something without bitmask smoothing. What?")
		return COMPONENT_INCOMPATIBLE

	reset_icon()
	RegisterSignal(parent, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_junction_change))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(update_icon))
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/datum/component/window_smoothing/proc/reset_icon()
	var/atom/parent_atom = parent
	if(!parent_atom.icon)
		return
	if(icon_path != parent_atom.icon)
		if(icon_path)
			remove_smoothing()
		icon_path = parent_atom.icon
		add_smoothing(parent_atom.smoothing_junction)
	parent_atom.icon = ""

/datum/component/window_smoothing/proc/add_smoothing(new_junction)
	var/atom/parent = src.parent

	if(!parent.loc) //we shouldnt add frills if we're in nullspace
		return

	var/junction = new_junction

	if(isnull(junction))
		junction = parent.smoothing_junction

	var/turf/our_turf = get_turf(parent)
	var/offset = GET_Z_PLANE_OFFSET(our_turf.z)
	// Alright. First we're gonna decide how to display our lower section
	// So we'll start with "do we have a wall down there"
	// we check to the south east and west too because action hates me
	// OF NOTE:
	// what we are checking here is if there's a wall below, OR if there's a wall to the south(east|west) and
	// a SMOOTHING TARGET to the south.
	// This ensures we only use the alt display if there's a wall there, AND we're smoothing into it
	var/wall_below = (isclosedturf(get_step(our_turf, SOUTH)) && (!ignored_turf || !istype(get_step(our_turf, SOUTH), ignored_turf))) || \
		((junction & SOUTH) && isclosedturf(get_step(our_turf, SOUTHEAST)) && (!ignored_turf || !istype(get_step(our_turf, SOUTHWEST), ignored_turf))) || \
		((junction & SOUTH) && isclosedturf(get_step(our_turf, SOUTHWEST)) && (!ignored_turf || !istype(get_step(our_turf, SOUTHWEST), ignored_turf)))
	// If there's a wall below us, we render different
	our_appearances += get_window_appearance(offset, icon_path, junction, "lower", wall_below)

	if(paired_turf)
		stack_trace("We tried to generate a connection to a turf while one already exists")
	// Now we'll check above
	// If there's nothin, we'll use a frill. Otherwise we won't
	paired_turf = get_step(our_turf, NORTH)
	// wallening TODO: ok this shit ain't working. Instead of trying to track walls like this, we should attach an effect object to the turf of our window that smooths for walls, and pass that into window logic

	// We only display an above state if there's a wall, OR if we're smoothing with nothing up there
	if(isclosedturf(paired_turf) && (!ignored_turf || !istype(paired_turf, ignored_turf)))
		our_appearances += get_window_appearance(offset, icon_path, junction, "upper", TRUE, pixel_y = 32)
		UnregisterSignal(paired_turf, COMSIG_QDELETING)
	else if(!(junction & NORTH))
		// Draw to the turf above you so this can be seen without seeing the window's turf. Oh and draw this as a frill
		// We use the parent's pixel y as a part of this to ensure everything lines up proper when the parent is all shifted around
		appearance_above = get_window_appearance(offset, icon_path, junction, "upper", FALSE, pixel_y = parent.pixel_y, plane = FRILL_PLANE)
		paired_turf.add_overlay(appearance_above)
		RegisterSignal(paired_turf, COMSIG_QDELETING, PROC_REF(tied_turf_deleted), override = TRUE) // Override because this could be called multiple times
	else
		UnregisterSignal(paired_turf, COMSIG_QDELETING)

	parent.add_overlay(our_appearances)

/datum/component/window_smoothing/proc/remove_smoothing()
	var/atom/atom_parent = parent
	atom_parent.cut_overlay(our_appearances)
	our_appearances.Cut()

	paired_turf.cut_overlay(appearance_above)
	paired_turf = null

/datum/component/window_smoothing/Destroy()
	remove_smoothing()
	return ..()

/datum/component/window_smoothing/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	remove_smoothing()
	add_smoothing(new_junction)

/datum/component/window_smoothing/proc/update_icon(datum/source)
	SIGNAL_HANDLER
	reset_icon()

/datum/component/window_smoothing/proc/tied_turf_deleted(turf/source)
	SIGNAL_HANDLER
	remove_smoothing()
	add_smoothing()

/datum/component/window_smoothing/proc/on_moved(atom/movable/parent, turf/old_turf, dir)
	SIGNAL_HANDLER
	remove_smoothing()
	add_smoothing()
