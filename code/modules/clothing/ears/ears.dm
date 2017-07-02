
//Ears: currently only used for headsets and earmuffs
/obj/item/clothing/ears
	name = "ears"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = SLOT_EARS
	resistance_flags = 0

/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	strip_delay = 15
	equip_delay_other = 25
	resistance_flags = FLAMMABLE

/obj/item/clothing/ears/earmuffs/Initialize(mapload)
	..()
	SET_SECONDARY_FLAG(src, BANG_PROTECT)
	SET_SECONDARY_FLAG(src, HEALS_EARS)

/obj/item/clothing/ears/headphones
	name = "headphones"
	desc = "Unce unce unce unce. Boop!"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "headphones_off"
	item_state = "headphones_off"
	slot_flags = SLOT_EARS | SLOT_HEAD | SLOT_NECK		//Fluff item, put it whereever you want!
	actions_types = list(/datum/action/item_action/toggle_headphones)
	var/icon_state_on = "headphones_on"
	var/icon_state_off = "headphones_off"
	var/item_state_on = "headphones_on"
	var/item_state_off = "headphones_off"
	var/headphones_on = FALSE

/obj/item/clothing/ears/headphones/ui_action_click(owner, action)
	headphones_on = !headphones_on
	if(headphones_on)
		item_state = item_state_on
		icon_state = icon_state_on
	else
		item_state = item_state_off
		icon_state = icon_state_off
	owner.update_inv_ears()
	to_chat(owner, "<span class='notice'>You turn the music [headphones_on? "on. Untz Untz Untz!" : "off."]</span>")
