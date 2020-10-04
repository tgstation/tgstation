/datum/action/item_action/rig
	background_icon_state = "bg_tech_blue"
	icon_icon = 'icons/mob/actions/actions_rig.dmi'
	var/obj/item/rig/control/rig

/datum/action/item_action/rig/New(Target)
	..()
	rig = Target

/datum/action/item_action/rig/Grant(mob/M)
	if(owner)
		return
	..()

/datum/action/item_action/rig/deploy
	name = "Deploy RIGsuit"
	desc = "Deploy/Conceal a part of the RIGsuit."
	button_icon_state = "deploy"

/datum/action/item_action/rig/deploy/Trigger()
	rig.choose_deploy(usr)

/datum/action/item_action/rig/activate
	name = "Activate RIGsuit"
	desc = "Activate/Deactivate the RIGsuit."
	button_icon_state = "activate"

/datum/action/item_action/rig/activate/Trigger()
	rig.toggle_activate(usr)

/datum/action/item_action/rig/panel
	name = "RIGsuit Panel"
	desc = "Open the RIGsuit's panel."
	button_icon_state = "panel"

/datum/action/item_action/rig/panel/Trigger()
	rig.ui_interact(usr)
