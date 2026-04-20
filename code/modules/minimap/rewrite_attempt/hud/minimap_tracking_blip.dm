
/atom/movable/screen/minimap_blip
	name = ""
	icon = 'icons/ui_icons/minimap/map_blips.dmi'
	layer = MINIMAP_BLIPS_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_PLANE
	/// Is this a large blip? causes different pixel offsets to be applied
	var/large = FALSE
	/// Minimap datum for the current z-level this blip is on
	var/datum/minimap/minimap
	/// If we are tracking our target or not, to ensure we do not re-register multiple times
	var/tracking = FALSE
	/// what target we're essentially owned by, and will cause this blip to cleanup if it gets deleted
	var/atom/track_target
	/// the tag this blip is associated via in it's stored globalist
	var/blip_tag = ""

/atom/movable/screen/minimap_blip/Initialize(mapload, datum/hud/hud_owner, atom/track_target, icon_state, icon, large = FALSE, blip_tag)
	. = ..()
	src.icon_state = icon_state
	src.large = large
	if(icon)
		src.icon = icon
	if(track_target)
		register_target(track_target)
	if(blip_tag)
		src.blip_tag = blip_tag

/atom/movable/screen/minimap_blip/Destroy()
	. = ..()
	GLOB.minimap_blip_tags -= src

/atom/movable/screen/minimap_blip/proc/register_target(atom/target)
	RegisterSignal(track_target, COMSIG_QDELETING, TYPE_PROC_REF(/datum, selfdelete), override = TRUE)
	track_target = target

/atom/movable/screen/minimap_blip/proc/start_tracking_target()
	if(tracking)
		return
	RegisterSignals(track_target, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(update_blip))
	tracking = TRUE
	INVOKE_ASYNC(src, PROC_REF(delayed_setup))

/atom/movable/screen/minimap_blip/proc/delayed_setup()
	minimap = get_minimap_for_z(track_target.z)
	update_blip()

/atom/movable/screen/minimap_blip/proc/update_blip()
	SIGNAL_HANDLER
	var/half_size = large ? 5 : 3
	pixel_w = MINIMAP_WORLD_TO_PIXEL(track_target.x, minimap.min_x, half_size)
	pixel_z = MINIMAP_WORLD_TO_PIXEL(track_target.y, minimap.min_y, half_size)

