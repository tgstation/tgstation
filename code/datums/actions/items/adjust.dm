/datum/action/item_action/adjust
	name = "Adjust Item"

/datum/action/item_action/adjust/New(Target)
	..()
	var/obj/item/item_target = target
	name = "Adjust [item_target.name]"
