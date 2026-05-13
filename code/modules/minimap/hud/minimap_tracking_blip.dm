/atom/movable/screen/minimap_element/blip
	icon = 'icons/ui_icons/minimap/map_blips.dmi'
	/// Is this a large blip? causes different pixel offsets to be applied
	var/large = FALSE
	/// Minimap datum for the current z-level this blip is on
	var/datum/minimap/minimap
	/// If we are tracking our target or not, to ensure we do not re-register multiple times
	var/tracking = FALSE
	/// what target we're essentially owned by, and will cause this blip to cleanup if it gets deleted
	var/atom/track_target
	/// The outermost movable container of track_target, so we can follow movement through nested contents
	var/atom/movable/tracked_container

/atom/movable/screen/minimap_element/blip/Initialize(mapload, datum/hud/hud_owner, atom/track_target, icon_state, icon, large = FALSE, blip_tag)
	. = ..()
	src.icon_state = icon_state
	src.large = large
	if(icon)
		src.icon = icon
	if(track_target)
		register_target(track_target)
	if(blip_tag)
		src.blip_tag = blip_tag

/atom/movable/screen/minimap_element/blip/Destroy()
	clear_tracking_signals()
	for(var/tag in GLOB.minimap_blip_tags)
		LAZYREMOVE(GLOB.minimap_blip_tags[tag], src)
	return ..()

/atom/movable/screen/minimap_element/blip/proc/register_target(atom/target)
	if(!isnull(track_target))
		CRASH("[type] attempted to register [target] while already tracking [track_target].")
	if(isnull(target))
		CRASH("[type] attempted to register a null track target.")
	RegisterSignal(target, COMSIG_QDELETING, TYPE_PROC_REF(/datum, selfdelete), override = TRUE)
	track_target = target
	name = target.name

/atom/movable/screen/minimap_element/blip/proc/clear_tracking_signals()
	if(track_target)
		UnregisterSignal(track_target, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED, COMSIG_ATOM_ENTERING, COMSIG_ATOM_EXITING))
	track_target = null
	tracking = FALSE
	if(tracked_container)
		UnregisterSignal(tracked_container, COMSIG_MOVABLE_MOVED)
		tracked_container = null

/atom/movable/screen/minimap_element/blip/proc/start_tracking_target()
	if(tracking)
		return
	if(isnull(track_target))
		CRASH("[type] cannot start tracking without a registered target.")
	RegisterSignal(track_target, COMSIG_MOVABLE_MOVED, PROC_REF(update_blip))
	RegisterSignal(track_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_z_changed))
	RegisterSignal(track_target, COMSIG_ATOM_ENTERING, PROC_REF(on_target_entering))
	RegisterSignal(track_target, COMSIG_ATOM_EXITING, PROC_REF(on_target_exiting))
	tracking = TRUE
	INVOKE_ASYNC(src, PROC_REF(update_minimap))

/atom/movable/screen/minimap_element/blip/proc/update_minimap()
	minimap = get_minimap_for_z(track_target.z)
	update_blip()

/atom/movable/screen/minimap_element/blip/proc/on_target_z_changed(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(isnull(track_target))
		return
	if(isnull(minimap) || minimap.z != track_target.z)
		INVOKE_ASYNC(src, PROC_REF(update_minimap))
	else
		// todo check if COMSIG_MOVABLE_MOVED is called anyway
		update_blip()

/atom/movable/screen/minimap_element/blip/proc/on_target_entering(atom/movable/source, atom/new_loc, atom/old_loc)
	SIGNAL_HANDLER
	var/atom/movable/new_container = get_outermost_movable_loc(new_loc)
	if(tracked_container == new_container)
		return
	if(tracked_container)
		UnregisterSignal(tracked_container, COMSIG_MOVABLE_MOVED)
	tracked_container = new_container
	if(tracked_container)
		RegisterSignal(tracked_container, COMSIG_MOVABLE_MOVED, PROC_REF(update_blip))

/atom/movable/screen/minimap_element/blip/proc/on_target_exiting(atom/movable/source, atom/old_loc, direction)
	SIGNAL_HANDLER
	// Clean up before entering the next loc; on_target_entering will rebind as needed.
	if(tracked_container)
		UnregisterSignal(tracked_container, COMSIG_MOVABLE_MOVED)
		tracked_container = null

/atom/movable/screen/minimap_element/blip/proc/get_outermost_movable_loc(atom/start_loc)
	var/atom/current = start_loc
	while(!isnull(current) && !isturf(current))
		// Once the current atom is directly on a turf, we've reached the outermost container.
		if(isnull(current.loc) || isturf(current.loc))
			return current
		current = current.loc

/atom/movable/screen/minimap_element/blip/proc/update_blip()
	SIGNAL_HANDLER
	if(isnull(track_target) || isnull(minimap))
		return
	name = track_target.name
	var/turf/target_turf = get_turf(track_target)
	var/half_size = large ? 5 : 3
	pixel_w = MINIMAP_WORLD_TO_PIXEL(target_turf.x, minimap.min_x, half_size)
	pixel_z = MINIMAP_WORLD_TO_PIXEL(target_turf.y, minimap.min_y, half_size)

