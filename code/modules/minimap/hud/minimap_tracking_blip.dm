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
	/// Weak reference to connect_containers so container movement updates this blip.
	var/datum/weakref/connect_ref

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
	tracking = FALSE
	if(track_target)
		UnregisterSignal(track_target, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOVABLE_MOVED))
		track_target.maptext = null
		track_target = null
	QDEL_NULL(connect_ref)

/atom/movable/screen/minimap_element/blip/proc/start_tracking_target()
	if(tracking)
		return
	if(isnull(track_target))
		CRASH("[type] cannot start tracking without a registered target.")
	RegisterSignal(track_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_z_changed))
	RegisterSignal(track_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_tracked_or_container_moved))
	if(ismovable(track_target))
		var/static/list/container_connections = list(
			COMSIG_MOVABLE_MOVED = PROC_REF(on_tracked_or_container_moved),
			COMSIG_MOVABLE_Z_CHANGED = PROC_REF(on_target_z_changed),
		)
		connect_ref = WEAKREF(AddComponent(/datum/component/connect_containers, track_target, container_connections))
	tracking = TRUE
	INVOKE_ASYNC(src, PROC_REF(update_minimap))

/atom/movable/screen/minimap_element/blip/proc/update_minimap()
	var/turf/target_turf = get_turf(track_target)
	minimap = get_minimap_for_z(target_turf.z)
	update_blip()

/atom/movable/screen/minimap_element/blip/proc/on_target_z_changed(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(isnull(track_target))
		return
	var/turf/target_turf = get_turf(track_target)
	if(isnull(minimap) || minimap.z != target_turf?.z)
		INVOKE_ASYNC(src, PROC_REF(update_minimap))
	else
		update_blip()

/atom/movable/screen/minimap_element/blip/proc/on_tracked_or_container_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	update_blip()

/atom/movable/screen/minimap_element/blip/proc/update_blip()
	SIGNAL_HANDLER
	if(isnull(track_target) || isnull(minimap))
		return
	name = track_target.name
	var/turf/target_turf = get_turf(track_target)
	var/half_size = large ? 5 : 3
	pixel_w = MINIMAP_WORLD_TO_PIXEL(target_turf.x, minimap.min_x, half_size)
	pixel_z = MINIMAP_WORLD_TO_PIXEL(target_turf.y, minimap.min_y, half_size)

