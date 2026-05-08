
/datum/action/minimap_new
	name = "Toggle Minimap"
	button_icon = 'icons/hud/implants.dmi'
	button_icon_state = "minimap"
	/// Optional minimap blip tags to render on the rewrite minimap display.
	var/list/minimap_blip_tags = list()
	/// Optional annotation sharing tag for minimap drawings/labels.
	var/annotation_share_tag
	/// list of hud elements we add and remove and check for when this action is triggered
	var/list/huds = list(
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
		to_chat(clicker, span_notice("Minimap hidden."))
		return

	if(SEND_SIGNAL(clicker, COMSIG_MINIMAP_ACTION_TRIGGER) & COMSIG_MINIMAP_ACTION_TRIGGER_CANCEL)
		return

	var/datum/minimap/minimap = get_minimap_for_z(clicker.z)
	if(isnull(minimap))
		to_chat(clicker, span_notice("No minimap generated for z=[clicker.z]."))
		return
	add_huds(hud, minimap)
	to_chat(clicker, span_notice("Minimap shown for z=[clicker.z]."))

/datum/action/minimap_new/proc/has_minimap_huds(datum/hud/hud)
	for(var/element in huds)
		if(hud.screen_objects[element])
			return TRUE
	return FALSE

/datum/action/minimap_new/proc/add_huds(datum/hud/hud, datum/minimap/minimap)
	for(var/element in huds)
		var/hud_element_type = huds[element]
		var/instanced = new hud_element_type(null, hud, minimap, minimap_blip_tags, null, annotation_share_tag)
		hud.add_screen_object(instanced, element, HUD_GROUP_STATIC, update_screen = TRUE)

/datum/action/minimap_new/nuclear
	annotation_share_tag = MINIMAP_ANNOTATION_TAG_NUCLEAR
	huds = list(
		HUD_TAC_MINIMAP = /atom/movable/screen/minimap_display/nuclear,
		HUD_TAC_MINIMAP_Z_INDICATOR = /atom/movable/screen/minimap_z_indicator,
		HUD_TAC_MINIMAP_Z_INDICATOR_UP = /atom/movable/screen/minimap_z_up,
		HUD_TAC_MINIMAP_Z_INDICATOR_DOWN = /atom/movable/screen/minimap_z_down
	)

/datum/action/minimap_new/proc/remove_huds(datum/hud/hud)
	for(var/element in huds)
		hud.remove_screen_object(element)

/mob/Initialize(mapload)
	. = ..()
	var/datum/action/minimap_new/minimap_action = new
	minimap_action.Grant(src)
