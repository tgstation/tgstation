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

/datum/action/item_action/mod/Trigger()
	if(!IsAvailable())
		return FALSE
	if(mod.malfunctioning && prob(75))
		mod.balloon_alert(usr, "button malfunctions!")
		return FALSE
	return TRUE

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Deploy/Conceal a part of the MODsuit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger()
	. = ..()
	if(!.)
		return
	mod.choose_deploy(usr)

/datum/action/item_action/mod/deploy/pai
	pai_action = TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Activate/Deactivate the MODsuit."
	button_icon_state = "activate"

/datum/action/item_action/mod/activate/Trigger()
	. = ..()
	if(!.)
		return
	mod.toggle_activate(usr)

/datum/action/item_action/mod/activate/pai
	pai_action = TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger()
	. = ..()
	if(!.)
		return
	mod.quick_module(usr)

/datum/action/item_action/mod/module/pai
	pai_action = TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger()
	. = ..()
	if(!.)
		return
	mod.ui_interact(usr)

/datum/action/item_action/mod/panel/pai
	pai_action = TRUE

/datum/action/item_action/mod/pinned_module
	desc = "Activate the module."
	var/obj/item/mod/module/module
	var/mob/pinner

/datum/action/item_action/mod/pinned_module/New(Target, obj/item/mod/module/linked_module, mob/user)
	if(user == mod.ai)
		ai_action = TRUE
	..()
	module = linked_module
	name = "Activate [capitalize(linked_module.name)]"
	icon_icon = linked_module.icon
	button_icon_state = linked_module.icon_state
	pinner = user

/datum/action/item_action/mod/pinned_module/Grant(mob/user)
	if(user != pinner)
		return
	return ..()

/datum/action/item_action/mod/pinned_module/Trigger()
	. = ..()
	if(!.)
		return
	module.on_select()
