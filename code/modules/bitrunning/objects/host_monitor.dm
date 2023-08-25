/obj/item/bitrunning_host_monitor
	name = "host monitor"

	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 2)
	desc = "A complex medical device that, when attached to an avatar's data stream, can detect the user of their host's health."
	flags_1 = CONDUCT_1
	icon = 'icons/obj/device.dmi'
	icon_state = "gps-b"
	inhand_icon_state = "electronic"
	item_flags = NOBLUDGEON
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	throw_range = 7
	throw_speed = 3
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	worn_icon_state = "electronic"

/obj/item/bitrunning_host_monitor/attack_self(mob/user, modifiers)
	. = ..()

	var/datum/mind/our_mind = user.mind
	var/mob/living/pilot = our_mind.pilot_ref?.resolve()
	if(isnull(pilot))
		balloon_alert(user, "data not recognized")
		return

	to_chat(user, span_notice("Current host health: [pilot.health / pilot.maxHealth * 100]%"))
