/datum/action/item_action/berserk_mode
	name = "Berserk"
	desc = "Increase your movement and melee speed while also increasing your melee armor for a short amount of time."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "berserk_mode"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

/datum/action/item_action/berserk_mode/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/clothing/head/hooded/berserker/berserk = target
	berserk.berserk_mode(owner)
	return TRUE

/datum/action/item_action/berserk_mode/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(target, /obj/item/clothing/head/hooded/berserker))
		return FALSE

	var/obj/item/clothing/head/hooded/berserker/berserk = target
	if(berserk.berserk_active)
		if(feedback)
			to_chat(owner, span_warning("You are already berserk!"))
		return FALSE
	if(berserk.berserk_charge < 100)
		if(feedback)
			to_chat(owner, span_warning("You don't have a full charge."))
		return FALSE
	return TRUE
