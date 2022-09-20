//Presets for item actions
/datum/action/item_action
	name = "Item Action"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS
	button_icon_state = null
	/// Does our item action uses the target's icon in it?
	/// Automatically set to FALSE if the button icon state non-null
	var/button_uses_target_icon = TRUE

/datum/action/item_action/New(Target)
	. = ..()
	if(!target || !button_uses_target_icon)
		return

	if(button_icon_state)
		button_uses_target_icon = FALSE
		return

	AddComponent(/datum/component/action_item_overlay)

/datum/action/item_action/vv_edit_var(var_name, var_value)
	. = ..()
	if(!.)
		return

	// vv-ing button_uses_target_icon will either add or remove the component
	if(var_name == NAMEOF(src, button_uses_target_icon))
		if(var_value)
			button_uses_target_icon = TRUE
			AddComponent(/datum/component/action_item_overlay)
		else
			button_uses_target_icon = FALSE
			qdel(GetComponent(/datum/component/action_item_overlay))

		build_all_button_icons(UPDATE_BUTTON_OVERLAY)

	// vv-ing the button icon state to null will add component, or off of null will remove the component
	if(var_name == NAMEOF(src, button_icon_state))
		if(button_uses_target_icon)
			button_uses_target_icon = FALSE
			qdel(GetComponent(/datum/component/action_item_overlay))

		else if(isnull(var_value))
			button_uses_target_icon = TRUE
			AddComponent(/datum/component/action_item_overlay)

		build_all_button_icons(UPDATE_BUTTON_OVERLAY)

/datum/action/item_action/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(target)
		var/obj/item/item_target = target
		item_target.ui_action_click(owner, src)
	return TRUE
