
/datum/action/minimap_new
	name = "Toggle Minimap"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "minimap"
	/// Mob currently bound to z-change signal handling for auto-hide behavior.
	var/mob/tracked_owner
	/// Optional fixed z-level for this action's minimap display.
	var/fixed_z_level
	/// Optional minimap blip tags to render on the rewrite minimap display.
	var/list/minimap_blip_tags = list()
	/// Optional annotation sharing tag for minimap drawings/labels.
	var/annotation_share_tag
	/// Whether this action's minimap display should allow drawing tools.
	var/can_draw = FALSE
	/// list of hud elements we add and remove and check for when this action is triggered
	var/list/huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down
	)

/datum/action/minimap_new/Trigger(mob/clicker, trigger_flags)
	. = ..()
	var/datum/hud/hud = clicker.hud_used
	// Toggle off if already visible.
	if(has_minimap_huds(hud))
		remove_huds(hud)
		clicker.balloon_alert(clicker, "minimap hidden")
		return

	if(SEND_SIGNAL(clicker, COMSIG_MINIMAP_ACTION_TRIGGER) & COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL)
		return

	if(is_forbidden_minimap_z(clicker?.z))
		to_chat(clicker, span_warning("The minimap cannot be used on this z-level."))
		clicker.balloon_alert(clicker, "invalid z-level!")
		return

	var/display_z = isnull(fixed_z_level) ? clicker.z : fixed_z_level
	var/datum/minimap/minimap = get_minimap_for_z(display_z)
	if(isnull(minimap))
		clicker.balloon_alert(clicker, "no minimap generated")
		return
	add_huds(hud, minimap)
	clicker.balloon_alert(clicker, "minimap shown")

/datum/action/minimap_new/Grant(mob/grant_to)
	. = ..()
	set_tracked_owner(grant_to)

/datum/action/minimap_new/Remove(mob/remove_from)
	set_tracked_owner(null)
	return ..()

/datum/action/minimap_new/proc/has_minimap_huds(datum/hud/hud)
	for(var/element in huds)
		if(hud.screen_objects[element])
			return TRUE
	return FALSE

/datum/action/minimap_new/proc/add_huds(datum/hud/hud, datum/minimap/minimap)
	for(var/element in huds)
		var/hud_element_type = huds[element]
		var/instanced = new hud_element_type(null, hud, minimap, minimap_blip_tags, fixed_z_level, annotation_share_tag, can_draw)
		hud.add_screen_object(instanced, element, HUD_GROUP_STATIC, update_screen = TRUE)

/datum/action/minimap_new/proc/set_tracked_owner(mob/new_owner)
	if(tracked_owner == new_owner)
		return
	if(!isnull(tracked_owner))
		UnregisterSignal(tracked_owner, COMSIG_MOVABLE_Z_CHANGED)
	tracked_owner = new_owner
	if(!isnull(tracked_owner))
		RegisterSignal(tracked_owner, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_owner_z_changed))

/datum/action/minimap_new/proc/is_forbidden_minimap_z(z_level)
	if(isnull(z_level))
		return FALSE
	return is_centcom_level(z_level) || is_reserved_level(z_level)

/datum/action/minimap_new/proc/on_owner_z_changed(atom/movable/source, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	if(!is_forbidden_minimap_z(new_turf?.z))
		return
	var/mob/owner_mob = source
	var/datum/hud/owner_hud = owner_mob?.hud_used
	if(!isnull(owner_hud) && has_minimap_huds(owner_hud))
		remove_huds(owner_hud)
		to_chat(owner_mob, span_warning("The minimap closes on this z-level."))

/datum/action/minimap_new/nuclear
	annotation_share_tag = MINIMAP_ANNOTATION_TAG_NUCLEAR
	huds = list(
		HUD_TAC_MINIMAP_DIMMER = /atom/movable/screen/fullscreen/dimmer/minimap,
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/nuclear,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down
	)

/datum/action/minimap_new/proc/remove_huds(datum/hud/hud)
	for(var/element in huds)
		hud.remove_screen_object(element)
