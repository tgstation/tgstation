/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce. Boop!"
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/accessories.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/ears.dmi'
	icon_state = "headphones"
	inhand_icon_state = "headphones"
	slot_flags = ITEM_SLOT_EARS | ITEM_SLOT_HEAD | ITEM_SLOT_NECK		//Fluff item, put it whereever you want!
	actions_types = list(/datum/action/item_action/toggle_headphones)
	var/headphones_on = FALSE
	custom_price = 60

/obj/item/clothing/ears/headphones/Initialize()
	. = ..()
	update_icon()

/obj/item/clothing/ears/headphones/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/ears/headphones/update_icon_state()
	icon_state = "[initial(icon_state)]_[headphones_on? "on" : "off"]"
	inhand_icon_state = "[initial(inhand_icon_state)]_[headphones_on? "on" : "off"]"

/obj/item/clothing/ears/headphones/proc/toggle(owner)
	headphones_on = !headphones_on
	update_icon()
	to_chat(owner, "<span class='notice'>You turn the music [headphones_on? "on. Untz Untz Untz!" : "off."]</span>")

/datum/action/item_action/toggle_headphones
	name = "Toggle Headphones"
	desc = "UNTZ UNTZ UNTZ"

/datum/action/item_action/toggle_headphones/Trigger()
	var/obj/item/clothing/ears/headphones/H = target
	if(istype(H))
		H.toggle(owner)
