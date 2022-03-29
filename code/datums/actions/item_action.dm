//Presets for item actions
/datum/action/item_action
	name = "Item Action"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null
	// If you want to override the normal icon being the item
	// then change this to an icon state

/datum/action/item_action/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(target)
		var/obj/item/I = target
		I.ui_action_click(owner, src)
	return TRUE

/datum/action/item_action/ApplyIcon(atom/movable/screen/movable/action_button/current_button, force)
	var/obj/item/item_target = target
	if(button_icon && button_icon_state)
		// If set, use the custom icon that we set instead
		// of the item appearence
		..()
	else if((target && current_button.appearance_cache != item_target.appearance) || force) //replace with /ref comparison if this is not valid.
		var/old_layer = item_target.layer
		var/old_plane = item_target.plane
		item_target.layer = FLOAT_LAYER //AAAH
		item_target.plane = FLOAT_PLANE //^ what that guy said
		current_button.cut_overlays()
		current_button.add_overlay(item_target)
		item_target.layer = old_layer
		item_target.plane = old_plane
		current_button.appearance_cache = item_target.appearance
