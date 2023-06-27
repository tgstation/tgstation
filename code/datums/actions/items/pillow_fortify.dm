/datum/action/item_action/pillow_fortify
	name = "Fortify"
	desc = "Decrease your speed and goes into a defensive stance countering any incoming shove."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "pillow_fortify"
	background_icon_state = "bg_default"
	overlay_icon_state = "bg_demon_border"

/datum/action/item_action/pillow_fortify/Trigger(trigger_flags)
	if(istype(target, /obj/item/clothing/suit/pillow_suit))
		var/obj/item/clothing/suit/pillow_suit/crazy_armor = target
		if(crazy_armor.hunkered)
			crazy_armor.end_fortify(owner)
			return
		if(!crazy_armor.hunkered)
			crazy_armor.fortify(owner)
			return
	return ..()
