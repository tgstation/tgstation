/datum/action/item_action/set_internals
	name = "Set Internals"
	default_button_position = SCRN_OBJ_INSERT_FIRST
	button_overlay_state = "ab_goldborder"

/datum/action/item_action/set_internals/UpdateButton(atom/movable/screen/movable/action_button/button, status_only = FALSE, force)
	. = ..()
	if(!. || !button) // no button available
		return
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	if(target == carbon_owner.internal)
		button.icon_state = "template_active"
