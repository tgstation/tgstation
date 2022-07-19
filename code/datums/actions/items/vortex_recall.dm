/datum/action/item_action/vortex_recall
	name = "Vortex Recall"
	desc = "Recall yourself, and anyone nearby, to an attuned hierophant beacon at any time.<br>If the beacon is still attached, will detach it."
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "vortex_recall"

/datum/action/item_action/vortex_recall/IsAvailable()
	var/area/current_area = get_area(target)
	if(!current_area || current_area.area_flags & NOTELEPORT)
		return FALSE
	if(istype(target, /obj/item/hierophant_club))
		var/obj/item/hierophant_club/teleport_stick = target
		if(teleport_stick.teleporting)
			return FALSE
	return ..()
