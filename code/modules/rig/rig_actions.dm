/datum/action/item_action/rig
	background_icon_state = "bg_tech_blue"

/datum/action/item_action/rig/deploy
	name = "Deploy RIGsuit"
	desc = "I hate all of you."
	var/obj/item/rig/control/rig

/datum/action/item_action/rig/deploy/New(Target)
	..()
	rig = Target

/datum/action/item_action/rig/deploy/Trigger()
	for(var/piece in list(rig.helmet,rig.chestplate,rig.gauntlets,rig.boots))
		rig.deploy(piece)
