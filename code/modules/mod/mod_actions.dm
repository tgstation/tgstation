/datum/action/item_action/mod
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_mod.dmi'
	var/obj/item/mod/control/mod

/datum/action/item_action/mod/New(Target)
	..()
	mod = Target

/datum/action/item_action/mod/Grant(mob/M)
	if(owner)
		return
	..()

/datum/action/item_action/mod/IsAvailable()
	if(owner == mod.ai)
		return TRUE
	return ..()

/datum/action/item_action/mod/deploy
	name = "Deploy MODsuit"
	desc = "Deploy/Conceal a part of the MODsuit."
	button_icon_state = "deploy"

/datum/action/item_action/mod/deploy/Trigger()
	mod.choose_deploy(usr)

/datum/action/item_action/mod/activate
	name = "Activate MODsuit"
	desc = "Activate/Deactivate the MODsuit."
	button_icon_state = "activate"

/datum/action/item_action/mod/activate/Trigger()
	mod.toggle_activate(usr)

/datum/action/item_action/mod/panel
	name = "MODsuit Panel"
	desc = "Open the MODsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/mod/panel/Trigger()
	mod.ui_interact(usr)
