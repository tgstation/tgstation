/datum/action/item_action/mod
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/obj/item/mod/control/mod

/datum/action/item_action/mod/New(Target)
	..()
	mod = Target

/datum/action/item_action/mod/Grant(mob/M)
	if(owner)
		Share(M)
		return
	..()

/datum/action/item_action/mod/Remove(mob/M)
	var/mob_to_grant
	for(var/datum/weakref/reference as anything in sharers)
		var/mob/freeloader = reference.resolve()
		if(!freeloader)
			continue
		mob_to_grant = freeloader
		break
	..()
	if(mob_to_grant)
		Grant(mob_to_grant)

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Deploy/Conceal a part of the MODsuit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.choose_deploy(usr)
	return TRUE

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Activate/Deactivate the MODsuit."
	button_icon_state = "activate"

/datum/action/item_action/mod/activate/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.toggle_activate(usr)
	return TRUE

/datum/action/item_action/mod/module
	name = "Toggle Module"
	desc = "Toggle a MODsuit module."
	button_icon_state = "module"

/datum/action/item_action/mod/module/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.quick_module(usr)
	return TRUE

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger()
	if(!IsAvailable())
		return FALSE
	mod.ui_interact(usr)
	return TRUE
