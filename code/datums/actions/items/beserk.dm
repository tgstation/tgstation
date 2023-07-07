/datum/action/item_action/berserk_mode
	name = "Berserk"
	desc = "Increase your movement and melee speed while also increasing your melee armor for a short amount of time."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "berserk_mode"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

/datum/action/item_action/berserk_mode/Trigger(trigger_flags)
	if(istype(target, /obj/item/clothing/head/hooded/berserker))
		var/obj/item/clothing/head/hooded/berserker/berzerk = target
		if(berzerk.berserk_active)
			to_chat(owner, span_warning("You are already berserk!"))
			return
		if(berzerk.berserk_charge < 100)
			to_chat(owner, span_warning("You don't have a full charge."))
			return
		berzerk.berserk_mode(owner)
		return
	return ..()
