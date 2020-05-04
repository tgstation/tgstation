/datum/action/item_action/rig
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/rig/deploy
	name = "Deploy RIGsuit"
	desc = "I hate all of you."
	var/obj/item/rig/control/rig = /obj/item/rig/control

/datum/action/item_action/rig/deploy/Trigger()
	for(var/piece in list(rig.helmet,rig.chestplate,rig.gauntlets,rig.boots))
		rig.deploy(piece)
