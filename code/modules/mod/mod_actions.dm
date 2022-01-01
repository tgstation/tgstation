/datum/action/item_action/mod
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	/// Whether this action is intended for the AI. Stuff breaks a lot if this is done differently.
	var/pai_action = FALSE
	/// The MODsuit linked to this action
	var/obj/item/mod/control/mod

/datum/action/item_action/mod/New(Target)
	..()
	mod = Target
	if(pai_action)
		background_icon_state = "bg_tech"

/datum/action/item_action/mod/Grant(mob/user)
	if(pai_action && user != mod.mod_pai)
		return
	else if(!pai_action && user == mod.mod_pai)
		return
	return ..()

/datum/action/item_action/mod/Remove(mob/user)
	if(pai_action && user != mod.mod_pai)
		return
	else if(!pai_action && user == mod.mod_pai)
		return
	return ..()

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Deploy/Conceal a part of the MODsuit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.choose_deploy(usr)
	return TRUE

/datum/action/item_action/mod/deploy/pai
	pai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Activate/Deactivate the MODsuit."
	button_icon_state = "activate"

/datum/action/item_action/mod/activate/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.toggle_activate(usr)
	return TRUE

/datum/action/item_action/mod/activate/pai
	pai_action = TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.quick_module(usr)
	return TRUE

/datum/action/item_action/mod/module/pai
	pai_action = TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.ui_interact(usr)
	return TRUE

/datum/action/item_action/mod/panel/pai
	pai_action = TRUE
