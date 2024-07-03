/datum/action/item_action/toggle_nv
	name = "Toggle Night Vision"
	var/stored_cutoffs
	var/stored_colour

/datum/action/item_action/toggle_nv/New(obj/item/clothing/glasses/target)
	. = ..()
	target.AddElement(/datum/element/update_icon_updates_onmob)

/datum/action/item_action/toggle_nv/Trigger(trigger_flags)
	if(istype(target, /obj/item/clothing/glasses))
		var/obj/item/clothing/glasses/goggles = target
		var/mob/holder = goggles.loc
		if(!istype(holder) || holder.get_slot_by_item(goggles) != ITEM_SLOT_EYES)
			holder = null
		if(stored_cutoffs)
			goggles.color_cutoffs = stored_cutoffs
			goggles.flash_protect = FLASH_PROTECTION_SENSITIVE
			stored_cutoffs = null
			if(stored_colour)
				goggles.change_glass_color(holder, stored_colour)
			playsound(goggles, 'sound/items/night_vision_on.ogg', 30, TRUE, -3)
		else
			stored_cutoffs = goggles.color_cutoffs
			stored_colour = goggles.glass_colour_type
			goggles.color_cutoffs = list()
			goggles.flash_protect = FLASH_PROTECTION_NONE
			if(stored_colour)
				goggles.change_glass_color(holder, null)
			playsound(goggles, 'sound/machines/click.ogg', 30, TRUE, -3)
		holder?.update_sight()
		goggles.update_appearance()
		return
	return ..()
